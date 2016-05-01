(function () {
    'use strict';

    angular.module('angularstrapApp.homeServices', [])
        .service('asyncService', asyncService);

    asyncService.$inject = ['$http', '$q'];

        function asyncService($http, $q) {
            
           var tasks= [{_id:"56c605b94f2db541c06b7b9672951a67",
                         status:1,
                        name:"Deliver shares to Jeffersonville",
                        bounty:5
                        },{_id:"cf13117b32a12e8220aa66943e8b9d7c",
                           status:2
                          },{_id:"cf13dkda12e8220aa66943e8b9d7c",
                           status:0
                          }]
           
           var balances = [50,42]
var structure =[tasks,balances]

            return structure;
        }
})();