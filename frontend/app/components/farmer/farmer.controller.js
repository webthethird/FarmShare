(function () {
    'use strict';

    angular.module('angularstrapApp')
        .controller('farmerController', farmerController);

    farmerController.$inject = ["$scope", "$http", "$window", "$q", "asyncService"];

    function farmerController($scope, $http, $window, $q, asyncService) {
var balances = asyncService[1]
        $scope.user = {userName:"Farmer Bill",
                       bcAddress:"8b4d75b283a0dc5a87cb4970cad180a4",
                       wallet:{balance:balances[1],address:"b046a46a8946bd09a43755320375a3fc"}
                       }
        //replace with a service call to retrieve tasks bound to his address
//        $scope.tasks = [{_id:"7ba88e6a1412daa1a833f9aae110b985",
//                         status:0
//                        },{_id:"170c955456546c4429e75e2a155a75ea",
//                           status:2
//                          },{_id:"fe1d47236bd25ca41eda6a383a086039",
//                           status:0
//                          }]
//                      
        $scope.tasks = asyncService[0];
        
        $scope.approve = function(task){
            task.status=0
            $scope.user.wallet.balance = $scope.user.wallet.balance-5;
            balances[1]=balances[1]-5;
            balances[0]=balances[0]+5;
        }               
        
        return $scope;
       }
})();