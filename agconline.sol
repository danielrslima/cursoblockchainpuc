pragma solidity 0.5.12;


contract AgcOnline {

    struct Proposta {
        string PlanoDeRecuperacao;
        address payable devedor;
        uint quantidadeTotaDeVotantesPresentesNaAssembleia;
        uint quantidadeTotalDeCreditoNaAssembleia;
        uint8 numeroDeClassesDeCredores;
        uint quorumMinimoParaAprovacaoDaAssembleia;
        bool existe;
        mapping(address=>Votante) quemVotou;
    }

    struct Votante {
        address payable enderecoVotante;
        string identificadorID;
        uint8 classeDeCredores;
        uint valorDoCreditoHabilitado;
        uint porcentagemSobreTotalDeCreditosVotanteDaClasse;
        uint porcentagemSobreTotalDeCreditoVotanteDaAssembleia;
        bool existe;
    }
    
    struct ClasseDeCredores {
        uint8 numeroDeClassesDeCredores;
        uint quantidadeDeVotantesPresentesPorClasse;
        uint quantidadeTotalDeCreditoVotantePorClasse;
        uint quorumMinimoParaAprovacaoPorClasse;        
        uint totalDeVotantesNaClasse;

    }    

    modifier somenteSecretario() {
        if (precisaSecretario) {
            require(secretario == msg.sender, "Só o secretário pode realizar essa operação");
        }
        _;
    }

    modifier somenteAdministradorJudicial() {
        require(administradorJudicial == msg.sender, "Somente o Administrador Judicial pode realizar essa operação");
        _;
    }

    //Dados Sobre a Assembleia
    Proposta[] propostas;
    mapping (address =>Votante) votantes;
    Votante[] numeroVotantes;
    address secretario;
    address administradorJudicial;
    uint dataInicioVotacao;
    uint dataFinalVotacao;
    bool precisaSecretario;
    
    constructor (bool PrecisaDeSecretario) public {
        administradorJudicial = msg.sender;
        precisaSecretario = PrecisaDeSecretario;
    }

    function designarSecretario(address secretarioDesignado) public somenteAdministradorJudicial {
        secretario = secretarioDesignado;
    }

   // unixtimestamp
    function dataAberturaVotacao(uint qualDataInicioVotacao) public somenteAdministradorJudicial {
        require(qualDataInicioVotacao > now, "A data informada deve ser maior que a atual");
        dataInicioVotacao = qualDataInicioVotacao;
    }
    
  // unixtimestamp
 
    function dataEncerramentoVotacao(uint qualDataFinalVotacao) public somenteAdministradorJudicial {
        require(qualDataFinalVotacao > now, "A data informada deve ser maior que a atual");
        dataFinalVotacao = qualDataFinalVotacao;
    }

    function incluiVotante(address payable enderecoVotante, string memory identificadorID, uint8 classeDeCredores,  uint valorDoCreditoHabilitado, uint porcentagemSobreTotalDeCreditosVotanteDaClasse, uint porcentagemSobreTotalDeCreditoVotanteDaAssembleia) public somenteSecretario {
        require(enderecoVotante != address(0), "O votante deve ter um endereco valido");
        Votante memory novoVotante = Votante(enderecoVotante, identificadorID, classeDeCredores, valorDoCreditoHabilitado, porcentagemSobreTotalDeCreditosVotanteDaClasse, porcentagemSobreTotalDeCreditoVotanteDaAssembleia, true);
        votantes[enderecoVotante] = novoVotante;
        numeroVotantes.push(novoVotante);
    }
    
          /** 
        @notice função a ser executada pelos votantes para registrar se aprovam ou não uma proposta
                A votação deve estar aberta para ser permitida
                Um votante só tem permissão de votar uma vez e o voto não pode ser alterado.
        @param numeroProposta - Numero identificador da proposta
        @param favoravelAProposta - 1 para se favoravel a proposta e 0 caso nao seja
        @return Verdadeiro caso o voto tenha sido computado com sucesso
        */
    
    function votar(uint numeroProposta, uint8 favoravelAProposta) public returns (bool) {
        emit FoiAUrna(now, msg.sender, numeroProposta, favoravelAProposta);
        require(dataFinalVotacao>=now, "Votacao encerrada");
        require(dataInicioVotacao<=now, "Votação ainda não foi aberta");
        Proposta storage propostaTemporario = propostas[numeroProposta];
        if (propostaTemporario.existe) {
            Votante storage votanteTemporario = votantes[msg.sender];
            if (votanteTemporario.existe) {
                if (!propostaTemporario.quemVotou[votanteTemporario.enderecoVotante].existe) {
                    if (favoravelAProposta > 0) {
                        propostaTemporario.quotaDeVotos = propostaTemporario.quotaDeVotos + votanteTemporario.quotaDeVotos;
                    }
                    emit Votou(msg.sender, numeroProposta, favoravelAProposta);
                    propostaTemporario.quemVotou[votanteTemporario.conta] = votanteTemporario;
                    return true;
                }
            } 
        } 
        return false;
    }
    
    function pesquisarVotante(address indiceVotante) public view returns (address, uint, uint8, string memory) {
        Votante memory votanteTemporario = votantes[indiceVotante];
        if (votanteTemporario.existe == true) {
            return (votanteTemporario.conta, votanteTemporario.valorDoCreditoHabilitado, votanteTemporario.classeDeCredores, votanteTemporario.identificadorID);
        } else {
            string memory none = "";
            return (address(0), 0, 0, none);
        }
    }

   
    function pesquisarVotantePorIndice(uint indiceVotante) public view returns (address, uint, uint, string memory) {
        require(indiceVotante <= numeroVotantes.length, "Indice informado é maior que o numero de votantes");
        Votante memory votanteTemporario = numeroVotantes[indiceVotante];
        if (votanteTemporario.existe == true) {
            return (votanteTemporario.conta, votanteTemporario.porcentagemSobreTotalDeCreditosVotanteDaClasse, votanteTemporario.porcentagemSobreTotalDeCreditoVotanteDaAssembleia, votanteTemporario.identificadorID);
        } else {
            string memory none = "";
            return (address(0), 0, 0, none);
        }
    }
    

    function totalDeVotantes() public view returns (uint) {
        return numeroVotantes.length;
    }


    //Evento a ser disparado quando um votante definiu seu voto
    event Votou(address indexed quemVotou, uint indexed propostaVotada, uint8 qualVoto);
    
    //Evento a ser disparado quando alguem tentou votar
    event FoiAUrna(uint indexed quando, address indexed quemVotou, uint indexed propostaVotada, uint8 qualVoto);
    

    /** 
    @notice Informa se a proposta foi aprovada ou não
    @return Verdadeiro (true) caso a proposta tenha recebidos votos (ou percentual de ações/participações) de apoio mínimo 
            para ser considerada aprovada
    */
    function propostaAprovada(uint numeroProposta) public view returns (bool)  {
        Proposta memory propostaTemporario = propostas[numeroProposta];
        if (propostaTemporario.existe) {
            return propostaTemporario.quotaDeVotos>=propostaTemporario.quotaMinimaParaAprovacao;
        } else {
            return false;
        }
    }

    /** 
    @notice Informa quando a votação se encerrará
    @return Unix timestamp de quando a votação será encerrada
    */
    function dataDeEncerramentoVotacao() public view returns (uint) {
        return dataFinalVotacao;
    }

}
