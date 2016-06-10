module.exports = {
  build: {
    "index.html": "index.html",
    "community.html": "community.html",
    "treasury.html": "treasury.html",
    "tasks.html": "tasks.html",
    "newTask.html": "newTask.html",
    "app.js": [
      "javascripts/app.js"
    ],
    "navbarDropdown.js": [
      "javascripts/navbarDropdown.js"
    ],
    "bignumber.js": [
      "javascripts/bignumber.js"
    ],
    "web3.js": [
      "javascripts/web3.js"
    ],
    "identicon.js": [
      "javascripts/identicon.js"
    ],
    "pnglib.js": [
      "javascripts/pnglib.js"
    ],
    "app.css": [
      "stylesheets/app.css"
    ],
    "images/": "images/"
  },
  deploy: [
    "FarmShare",
    "TaskBoard"
  ],
  rpc: {
    host: "localhost",
    port: 8545
  }
};
