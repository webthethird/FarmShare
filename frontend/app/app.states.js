/**
 * Load states for application
 * more info on UI-Router states can be found at
 * https://github.com/angular-ui/ui-router/wiki
 */
angular.module('angularstrapApp')
    .config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {

        // any unknown URLS go to 404
        $urlRouterProvider.otherwise('/404');
        // no route goes to index
        $urlRouterProvider.when('', '/');
        // use a state provider for routing

        $stateProvider
            .state('home', {
                url: '/',
                templateUrl: 'app/components/home/views/home.view.html',
                controller: "homeController",
                controllerAs: 'ctrl'
            })
            .state('404', {
                url: '/404',
                templateUrl: 'app/shared/404.html'
            })
            .state('products', {
                // we'll add another state soon
                url: '/products',
                templateUrl: 'app/components/products/views/products.view.html',
                controller: 'productsController',
                controllerAs: 'ctrl'
            })
            .state('profile', {
                // we'll add another state soon
                url: '/profile',
                templateUrl: 'app/components/profile/views/profile.view.html',
                controller: 'profileController',
                controllerAs: 'ctrl'
            })
        .state('farmer', {
                // we'll add another state soon
                url: '/farmer',
                templateUrl: 'app/components/farmer/views/farmer.view.html',
                controller: 'farmerController',
                controllerAs: 'ctrl'
            })
            .state('tasks', {
                // we'll add another state soon
                url: '/tasks',
                templateUrl: 'app/components/tasks/views/tasks.view.html',
                controller: 'tasksController',
                controllerAs: 'ctrl'
            });
}]);
