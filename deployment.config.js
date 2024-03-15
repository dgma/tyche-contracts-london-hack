const { VerifyPlugin } = require("@dgma/hardhat-sol-bundler/plugins/Verify");

const config = {
  Oracle: {},
};

module.exports = {
  hardhat: {
    config: config,
  },
  localhost: { lockFile: "./local.deployment-lock.json", config: config },
  baseSepolia: {
    lockFile: "./deployment-lock.json",
    verify: true,
    plugins: [VerifyPlugin],
    config: config,
  },
};
