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
    
    constructor( 
        string memory nomeLocador, string memory nomeLocatario, uint256 valorDoAluguel) public {
        locador = nomeLocador;
        locatario = nomeLocatario;
        valor = valorDoAluguel;
        }

// "contructor" sempre tem que ser publico

    function valorDoAluguel() public view returns (uint256) {
        return valor;
    }
    
    function simulaMulta (uint256 mesesRestantes, uint256 totalMesesContrato)
    public
    view
    returns(uint256 valorMulta) {
        valorMulta = valor*numeroMaximoLegalDeAlugueisParaMulta;
        valorMulta = valorMulta/totalMesesContrato;
        valorMulta = valorMulta*mesesRestantes;
        return valorMulta;
        
    }
        
}
