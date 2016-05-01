(function () {
    'use strict';

    angular.module('angularstrapApp')
        .controller('profileController', profileController);

    profileController.$inject = ["$scope", "$http", "$window", "$q", "asyncService"];

    function profileController($scope, $http, $window, $q, asyncService) {
var balances = asyncService[1]
        $scope.user = {userName:"William Bodell",
                       bcAddress:"9fadf8832631a0705f107c00349926ee",
                       wallet:{balance:balances[0],address:"b046a46a8946bd09a43755320375a3fc"}
                       }
        //replace with a service call to retrieve tasks bound to his address
//        $scope.tasks = [{_id:"56c605b94f2db541c06b7b9672951a67",
//                         status:1
//                        },{_id:"cf13117b32a12e8220aa66943e8b9d7c",
//                           status:2
//                          },{_id:"cf13dkda12e8220aa66943e8b9d7c",
//                           status:0
//                          }]
//                       
        $scope.tasks = asyncService[0]
        
                $scope.markComplete= function(bounty){
            bounty.status=4;

        }
                       
        
        return $scope;
       }
})();