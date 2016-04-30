contract Market {

  address seller;
  address buyer;

  uint productPrice;

  string productName;
  string stateMessage;
  string message;

  function Market() {
    seller = msg.sender;

    stateMessage = "Uploaded product smart contract";
    message = stateMessage;
  }

  function setUpProductDetails(uint price, string name) {
    stateMessage = "Product details set";
    message = stateMessage;
    productPrice = price;
    productName = name;
  }

  function buyerPurchasesProduct() {
    if (msg.value >= productPrice) {
      buyer = msg.sender;
      stateMessage = "Buyer purchased product";
      seller.send(this.balance);
      message = stateMessage;
    } else {
      msg.sender.send(msg.value);
      message = "Product not purchased. Refunded money";
    }
  }
}
