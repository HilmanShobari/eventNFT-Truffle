const routes = require('next-routes')();

routes
.add('/votings/new', '/votings/new')
.add('/votings/:address', '/votings/show');

module.exports = routes;