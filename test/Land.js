// test/Land.test.js
const { expect } = require("chai");

describe("Land", function () {
  it("Should deploy Land contract", async function () {
    const Land = await ethers.getContractFactory("Land");
    const land = await Land.deploy();
    await land.deployed();
    expect(await land.owner()).to.equal(await ethers.provider.getSigner(0).getAddress());
  });
});

// Set the script to run
// @custom:dev-run-script test
