pragma solidity >=0.5.12;

contract Escrow {
    
/*Escrow é uma garantia prevista em um contrato(p.ex. Compra e venda) ou acordo comercial que é mantida sob a responsabilidade de um terceiro(normalmente um banco) até que as cláusulas desse acordo sejam cumpridas por ambas as partes envolvidas no negócio;
Poderia dizer que o mercadopago se assemelha a um escrow (pois assegura que se o produto nao for recebido pelo comprador ele nao transfere o dinheiro ao vendedor */    
    
    address payable public comprador; 
    address payable public vendedor;
    uint256 public preco;
    bool public entregue;  
    
    constructor (address payable novo_comprador, address payable novo_vendedor, uint256 novo_preco) public {
        comprador = novo_comprador;
        vendedor = novo_vendedor;
        preco = novo_preco;
        entregue = false;
    }

    function pagamento () payable public {
        //O produto não pode ter sido entregue ainda
        require (!entregue, "Produto pago e entregue ");
        
        //Quem está enviando deve ser o comprador
        require (comprador == msg.sender, "Quem esta tentando pagar nao é o comprador");
        
        //O valor enviado deve ser igual ao preço
        require (msg.value == preco, "Valor diferente do preco");

        //entrega produto para o comprador
        entregue = true;
                
        //transfere valor para o vendedor
        if (preco > 0) {
            address(vendedor).transfer(msg.value);
        }
                
    } 
    
    function definirPartes (address payable _comprador, address payable _vendedor, uint256 _preco) public {
        //Só pode reiniciar se o produto já foi entregue
        require (entregue, "Em andamento, não é possível alterar"); 
        
        comprador = _comprador;
        vendedor = _vendedor;
        preco = _preco;
        entregue = false;
    }
} 
