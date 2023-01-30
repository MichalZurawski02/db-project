const mysql = require('mysql2');

const appPool = mysql.createConnection({
        host: '127.0.0.1',
        user: 'app',
        database: 'VinylStore',
        password: 'app',
        port: 3306
    }
);

const workerPool = mysql.createConnection({
        host: '127.0.0.1',
        user: 'worker',
        database: 'VinylStore',
        password: 'worker',
        port: 3306,
    }
);

const managerPool = mysql.createConnection({
        host: '127.0.0.1',
        user: 'manager',
        database: 'VinylStore',
        password: 'manager',
        port: 3306
    }
);

const adminPool = mysql.createConnection({
        host: '127.0.0.1',
        user: 'admin',
        database: 'VinylStore',
        password: 'admin',
        port: 3306
    }
);

module.exports = {appPool, workerPool, managerPool, adminPool};