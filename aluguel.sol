pragma solidity 0.5.12;

/* 
Sempre colocar barra-asterisco quando for iniciar comentario grande;
*/
//Ja se colocar 2 barras o comentario valera apenas para uma linha

contract Locacao {

/*
string = "Texto" (Sempre entre aspas)
uint (apelido de uint256) = numero inteiro
address = endereço ethereum
bool (boolean) = verdadeiro ou falso
constant = uint256 constant (tem sempre que informar o numero/valor)
*/

    string public locatario;
    string public locador;
    uint256 private valor;
    uint256 constant numeroMaximoLegalDeAlugueisParaMulta = 3;
    bool[] public statusPagamento;
    address payable public contaLocatario;
    
    constructor( 
        string memory nomeLocador, string memory nomeLocatario, address payable paramContaLocatario, uint256 valorDoAluguel) public 
    {
        locador = nomeLocador;
        locatario = nomeLocatario;
        valor = valorDoAluguel;
        contaLocatario = paramContaLocatario;
    }

// "contructor" sempre tem que ser publico
    function valorAtualDoAluguel() public view returns (uint256) 
    {
        return valor;
    }
    
    function simulaMulta (uint256 mesesRestantes, uint256 totalMesesContrato)
    public view returns(uint256 valorMulta) {
        valorMulta = valor*numeroMaximoLegalDeAlugueisParaMulta;
        valorMulta = valorMulta/totalMesesContrato;
        valorMulta = valorMulta*mesesRestantes;
        return valorMulta;
    }
    
    function reajustaAluguel(uint256 percentualReajuste) public 
    {
        if (percentualReajuste > 20)
        {
            percentualReajuste = 20;
        }
        uint256 valorDoAcrescimo = 0;
        valorDoAcrescimo = ((valor*percentualReajuste)/100);
        valor = valor + valorDoAcrescimo;
    }
    
    function retificacaoValorAluguel(uint256 valorCerto) public {
        valor = valorCerto;
    }
    
    function aplicaMulta (uint256 mesesRestantes, uint256 percentual) public
    {
        require(mesesRestantes <= 30, "Periodo de contrato invalido");
        for (uint256 i=1; i<mesesRestantes; i++) 
        {
            valor = valor+((valor*percentual)/100);
        }
    }
    
    function EfetuarPagamento() public payable 
    {
        require(msg.value>=valor, "Valor Insuficiente");
        contaLocatario.transfer(msg.value);
        statusPagamento.push(true);
        
    }    
}    
 
