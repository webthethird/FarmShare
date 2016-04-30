import "Treasury.sol";

//adapted from JobMarket contract by ultra-koder: https://github.com/ultra-koder/JobMarket/blob/master/dapp/contracts/jobmarket.sol
contract Market {
    uint32 public totalProducts;
  address public tokenAddress;

  event NewProduct(uint id, string name, string description);
  event NewSeller(string name, address addr);
  
  uint32[] productArray;
  address[] sellerArray;
  address[] buyerArray;
  
  mapping (uint => Product) products;
  mapping (address => Seller) sellers;
  mapping (address => Buyer) buyers;

  struct Seller {
        string name;
        address account;
        //uint tokenBalance;
  }
    
  struct Buyer {
        string name;
        address account;
        //uint tokenBalance;
  }

  struct Product {
        string name;
        string description;
        uint price;
        Seller seller;
        Buyer buyer;
  }

  function Market() {
    address treasuryAddress = address(new Treasury());
    Treasury treasury = Treasury(treasuryAddress);
        
    //tokenAddress = treasury.createToken();
  }


  function newSeller(string _name) public returns(uint sellerId) {
        Seller newSeller = sellers[msg.sender];
        newSeller.name = _name;
        newSeller.account = msg.sender;
        sellerArray.push(newSeller.account);
        
        NewSeller(newSeller.name, newSeller.account);
        return(sellerArray.length);
      
  }

  function newBuyer(string _name) public returns(uint buyerId) {
        Buyer newBuyer = buyers[msg.sender];
        newBuyer.name = _name;
        newBuyer.account = msg.sender;
        buyerArray.push(newBuyer.account);
        
        return(buyerArray.length);
  }

  function newProduct(string _name, string _description) public returns (uint32 taskId) {
        Product newProduct = products[totalProducts];
        newProduct.seller = sellers[msg.sender];
        newProduct.name = _name;
        newProduct.description = _description;
        // newProduct.status = ProductStatus.New;
        newProduct.price = msg.value;
        
        totalProducts++;
        // productArray.push(totalProducts);
        
        NewProduct(totalProducts, _name, _description);
        return(totalProducts);
  }
//function setTokenAddress(address _tokenAddress) public onlyowner returns(bool success) {
    //tokenAddress = _tokenAddress;
    //return true;
    // }
    
    function setProductPrice(uint _productId, uint _price, string _description) returns (bool success) {
        Product product = products[_productId - 1];
        if (product.seller.account == msg.sender) {
            product.price = _price;
        }
    }
        
    function getSellers() constant returns(address[] sList) {
        return(sellerArray);
    }
    
    function getProducts() constant returns(uint32[] pList) {
        return(productArray);
    }
    
    function getProductNames() constant {
        var list = productArray;
        for (uint i = 0; i < list.length; i++) {
            getProductName(i);
        }
    }
    
    function getSellerNames() constant {
        var list = sellerArray;
        for (uint i = 0; i < list.length; i++) {
            getSellerName(i);
        }
    }
    
    function getProductName(uint id) constant returns(string pName) {
        string name = products[id - 1].name;
        return(name);
    }
    
    function getSellerName(uint id) constant returns(string sName) {
        string name = sellers[sellerArray[id]].name;
        return(name);
    }
    
    function getProductDescription(uint id) constant returns(string pDescription) {
        string description = products[id - 1].description;
        return(description);
    }

    function getProductPrice(uint id) constant returns(uint price) {
        return(products[id - 1].price);
    }
    
    function getProductSellerName(uint id) constant returns(string seller) {
        string name = products[id - 1].seller.name;
        return(name);
    }
    
    function purchaseProduct(uint id) {
        Product product = products[id - 1];
        if (msg.sender == product.seller.account) {
           // balanceOf[tokenAddress] -= product.price;
           // balanceOf[task.volunteer.account] += product.price;
        }
    }
}