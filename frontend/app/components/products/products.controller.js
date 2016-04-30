(function () {
    'use strict';

    angular.module('angularstrapApp')
        .controller('productsController', productsController);

    homeController.$inject = ["$scope", "$http", "$window", "$q", "asyncService"];

    function homeController($scope, $http, $window, $q, asyncService) {

            var vm = this;

            //services


            // from async service
            vm.HeroHeader = "header";
            vm.HeroText ="text";

            // subsections
            vm.col0heading = "Subsections";
            vm.col0text = "I may populate this with a microservice! Or have this be a separate view. This template uses Angular UI which is better than using the Angular router in my opinion.";

            return vm;
       }
})();