const { VerifyPlugin } = require("@dgma/hardhat-sol-bundler/plugins/Verify");
const { dynamicAddress } = require("@dgma/hardhat-sol-bundler");

const config = {
  ArraySort: {},
  OracleMath: {},
  Oracle: {
    options: {
      libs: {
        ArraySort: dynamicAddress("ArraySort"),
        OracleMath: dynamicAddress("OracleMath"),
      },
    },
  },
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
