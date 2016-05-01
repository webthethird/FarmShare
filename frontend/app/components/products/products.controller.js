(function () {
    'use strict';

    angular.module('angularstrapApp')
        .controller('productsController', productsController);

    productsController.$inject = ["$scope", "$http", "$window", "$q", "asyncService"];

    function productsController($scope, $http, $window, $q, asyncService) {

        var products = [{productName:"Peppers",
                        vendorName:"Main Street Farm Market",
                        cost: "1 fs"},
                       {productName:"Apples",
                        vendorName:"Main Street Farm Market",
                        cost: "1 fs"},
                        {productName:"Green Peppers",
                        vendorName:"Main Street Farm Market",
                        cost: "1 fs"},
                        {productName:"Limes",
                        vendorName:"Main Street Farm Market",
                        cost: "1 fs"}
                       ]
                       
        $scope.products = products;
        
        $scope.addToCart = function(itemId){
            
        }
        
        return $scope;
       }
})();