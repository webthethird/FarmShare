(function () {
    'use strict';

    angular.module('angularstrapApp')
        .controller('productsController', productsController);

    productsController.$inject = ["$scope", "$http", "$window", "$q", "asyncService"];

    function productsController($scope, $http, $window, $q, asyncService) {

        var products = [{productName:"Peppers",
                        vendorName:"Main Street Farm Market",
                        cost: "1 ETH"},
                       {productName:"Apples",
                        vendorName:"Main Street Farm Market",
                        cost: "1 ETH"},
                        {productName:"Green Peppers",
                        vendorName:"Main Street Farm Market",
                        cost: "1 ETH"},
                        {productName:"Limes",
                        vendorName:"Main Street Farm Market",
                        cost: "1 ETH"}
                       ]
                       
        $scope.products = products;
        
        return $scope;
       }
})();