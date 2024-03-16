const { VerifyPlugin } = require("@dgma/hardhat-sol-bundler/plugins/Verify");
const { dynamicAddress } = require("@dgma/hardhat-sol-bundler");

const sharedConfig = {
  ArraySort: {},
  OracleMath: {},
};

const configBase = {
  ...sharedConfig,
  OracleBase: {
    options: {
      libs: {
        ArraySort: dynamicAddress("ArraySort"),
        OracleMath: dynamicAddress("OracleMath"),
      },
    },
  },
};

const configArbitrum = {
  ...sharedConfig,
  OracleArbitrum: {
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
    config: configBase,
  },
  localhost: { lockFile: "./local.deployment-lock.json", config: configBase },
  baseSepolia: {
    lockFile: "./deployment-lock.json",
    verify: true,
    plugins: [VerifyPlugin],
    config: configBase,
  },
  arbitrumSepolia: {
    lockFile: "./deployment-lock.json",
    verify: true,
    plugins: [VerifyPlugin],
    config: configArbitrum,
  },
};
