pragma solidity 0.5.12;

contract ERC20Interface {
    function totalSupply() public view returns(uint amount);
    //a função totalSupply () , que determina a quantidade total de tokens que serão criados para serem trocados na economia de token de um determinado projeto.
    function balanceOf(address tokenOwner) public view returns(uint balance);
    //balanceof e sempre a conta do mandatario
    function allowance(address tokenOwner, address spender) public view returns(uint balanceRemaining);
    //a função allowance () garante que as transações sejam válidas antes de serem adicionadas ao blockchain. Sempre que um usuário quiser transferir alguns tokens para outra carteira, essa função verifica se o endereço de envio tem pelo menos tantos tokens quanto o valor estipulado na função transferFrom (). Caso isso não aconteça, a transação não é válida
    function transfer(address to, uint tokens) public returns(bool status);
    //a função transfer () , que é usada para a distribuição inicial de tokens para as carteiras dos usuários. Essa função é a maior razão pela qual os tokens ERC-20 se tornaram tão populares para as ICOs, pois torna incrivelmente fácil enviar fichas aos investidores quando a OIC estiver concluída.
    function approve(address spender, uint limit) public returns(bool status);
    //A função approve () , Funciona como uma procuracao para trasnferir tokens em nome de outrem 
    //Pode ser tambem  usada para garantir que o fornecimento total de token dentro da economia seja mantido constante. Em outras palavras, essa função está em vigor para garantir que ninguém possa criar tokens adicionais do ar para se beneficiar
    //spender e um terceiro 
    function transferFrom(address from, address to, uint amount) public returns(bool status);
    //transferFrom () é o que permite que os detentores de tokens troquem tokens uns com os outros após a distribuição inicial. Supondo que você queira enviar uma BAT a um amigo, essa função pega o endereço da carteira do Ethereum, o endereço da carteira Ethereum do destinatário e a quantia enviada e, em seguida, executa a transação.
    function name() public view returns(string memory tokenName);
    function symbol() public view returns(string memory tokenSymbol);

    event Transfer(address from, address to, uint amount);
    event Approval(address tokenOwner, address spender, uint amount);
}

contract Owned {
    address payable contractOwner;

    constructor() public { 
        contractOwner = msg.sender; 
    }
    
    function whoIsTheOwner() public view returns(address) {
        return contractOwner;
    }
}


contract Mortal is Owned  {
    function kill() public {
        if (msg.sender == contractOwner) {
            selfdestruct(contractOwner);
        }
    }
}

contract TicketERC20 is ERC20Interface, Mortal {
    //is significa que o contrato pode herdar as funcionaidades de outros contratos, aqui no caso o erc20interface.
    string private myName;
    string private mySymbol;
    uint private myTotalSupply;
    uint8 public decimals;

    mapping (address=>uint) balances;
    mapping (address=>mapping (address=>uint)) ownerAllowances;

    constructor() public {
        myName = "EPD Creditos";
        mySymbol = "EPDC2019";
        myTotalSupply = 1000000;
        decimals = 0;
        balances[msg.sender] = myTotalSupply;
        //quem publicar o contrato ja tem o saldo EPDC2019
    }

    function name() public view returns(string memory tokenName) {
        return myName;
    }

    function symbol() public view returns(string memory tokenSymbol) {
        return mySymbol;
    }

    function totalSupply() public view returns(uint amount) {
        return myTotalSupply;
    }

    function balanceOf(address tokenOwner) public view returns(uint balance) {
        require(tokenOwner != address(0));
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns(uint balanceRemaining) {
        return ownerAllowances[tokenOwner][spender];
    }

    function transfer(address to, uint amount) public hasEnoughBalance(msg.sender, amount) tokenAmountValid(amount) returns(bool status) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint limit) public returns(bool status) {
        ownerAllowances[msg.sender][spender] = limit;
        emit Approval(msg.sender, spender, limit);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public 
    hasEnoughBalance(from, amount) isAllowed(msg.sender, from, amount) tokenAmountValid(amount)
    returns(bool status) {
        balances[from] -= amount;
        balances[to] += amount;
        ownerAllowances[from][msg.sender] = amount;
        emit Transfer(from, to, amount);
        return true;
    }

    modifier hasEnoughBalance(address owner, uint amount) {
        uint balance;
        balance = balances[owner];
        require (balance >= amount); 
        _;
    }

    modifier isAllowed(address spender, address tokenOwner, uint amount) {
        require (amount <= ownerAllowances[tokenOwner][spender]);
        _;
    }

    modifier tokenAmountValid(uint amount) {
        require(amount > 0);
        _;
    }

}       
