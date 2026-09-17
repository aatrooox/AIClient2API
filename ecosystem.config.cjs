module.exports = {
  apps: [
    {
      name: 'aiclient2api',
      script: 'src/core/master.js',
      cwd: __dirname,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      },
      out_file: './logs/pm2-out.log',
      error_file: './logs/pm2-error.log',
      merge_logs: true,
      time: true
    }
  ]
};
