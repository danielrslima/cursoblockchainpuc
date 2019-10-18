pragma solidity 0.5.12;

contract Leilao {

    struct Ofertante {
        // agrauoamento de determinadas variaveis 
        string nome;
        address payable enderecoCarteira;
        uint oferta;
        bool jaFoiReembolsado;
    }
    
    address payable public contaGovernamental;
    //qual conta vai receber o ether
    uint public prazoFinalLeilao;
    //pode ofertar ate acabar

    address public maiorOfertante;
    //guardar para fins de registro quem ganhou
    uint public maiorLance;

    mapping(address => Ofertante) public listaOfertantes;
    //e como um array[], so que ha situacoes que eu quero localizar algo pelo nome, endereco ou numero que eu "defina" 
    //o que muda e a forma que identifico o id 
    //entre parenteses eu defino o tipo de dado  
    //(string) tipo de dado que quero achar dentro
    //(ofertante) tipo de dado a ser armanezado
    Ofertante[] public ofertantes;

    bool public encerrado;
    //dizer se o leilao foi encerrado ou nao

    event novoMaiorLance(address ofertante, uint valor);
    //dispara a comunicacao se alguem deu lance novo maior
    event fimDoLeilao(address arrematante, uint valor);

    modifier somenteGoverno {
        require(msg.sender == contaGovernamental, "Somente Governo pode realizar essa operacao");
        _;
    }

    constructor(
        uint _duracaoLeilao,
        address payable _contaGovernamental
    ) public {
        contaGovernamental = _contaGovernamental;
        prazoFinalLeilao = now + _duracaoLeilao;
    }


    function lance(string memory nomeOfertante, address payable enderecoCarteiraOfertante) public payable {
        require(now <= prazoFinalLeilao, "Leilao encerrado.");
        require(msg.value > maiorLance, "Ja foram apresentados lances maiores.");
        //se o valor que alguem esta dando de lance e maior que o maior lance anterior
        
        maiorOfertante = msg.sender;
        maiorLance = msg.value;
        
        //Realizo estorno das ofertas aos perdedores
        /*
        For é composto por 3 parametros (separados por ponto virgula)
            1o  é o inicializador do indice
            2o  é a condição que será checada para saber se o continua 
                o loop ou não 
            3o  é o incrementador (ou decrementador) do indice
        */
        for (uint i=0; i<ofertantes.length; i++) {
            Ofertante storage leiloeiroPerdedor = ofertantes[i];
            // 
            if (!leiloeiroPerdedor.jaFoiReembolsado) {
                //quando tem uma condicao com uma exclamacao(!) estou comparando como false
                //se eu quisesse eu poderia escrever sem o (!) ficando como (leiloeiroPerdedor.jaFoiReembolsado == false)
                leiloeiroPerdedor.enderecoCarteira.transfer(leiloeiroPerdedor.oferta);
                leiloeiroPerdedor.jaFoiReembolsado = true;
            }
        }
        
        //Crio o ofertante
        Ofertante memory concorrenteVencedorTemporario = Ofertante(nomeOfertante, enderecoCarteiraOfertante, msg.value, false);
        //aqui adiciona o novo Ofertante vencedor temporario 
        
        //Adiciono o novo concorrente vencedor temporario no array de ofertantes
        ofertantes.push(concorrenteVencedorTemporario);
        
        //Adiciono o novo concorrente vencedor temporario na lista (mapa) de ofertantes
        listaOfertantes[concorrenteVencedorTemporario.enderecoCarteira] = concorrenteVencedorTemporario;
    
        emit novoMaiorLance (msg.sender, msg.value);
        //como se fosse o grito de novo lance 
    }

   
    function finalizaLeilao() public somenteGoverno {
        //que pode bater o martelo e so o governo
       
        require(now >= prazoFinalLeilao, "Leilao ainda nao encerrado.");
        require(!encerrado, "Leilao encerrado.");
        //requer aqui que o encerrado seja false

        encerrado = true;
        emit fimDoLeilao(maiorOfertante, maiorLance);

        contaGovernamental.transfer(address(this).balance);
        //transfira o saldo ou seja
        //manda a grana do lance para o governo
    }
}
