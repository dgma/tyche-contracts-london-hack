const { VerifyPlugin } = require("@dgma/hardhat-sol-bundler/plugins/Verify");
const { dynamicAddress } = require("@dgma/hardhat-sol-bundler");

const configBase = {
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

const configArbitrum = {
  ...configBase,
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
};
