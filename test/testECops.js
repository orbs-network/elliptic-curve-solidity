const ecops = artifacts.require("./ECops.sol");
const BigNumber = require("bignumber.js");
const data = require("./testData.js");


contract('ECC', async (accounts) => {

    it('scalar multiplication', async() => {
        let instance = await ecops.deployed();
        let testData = data.test;

        let generator = [
            "48439561293906451759052585252797914202762949526041747995844080717082404635286",
            "36134250956749795798585127919587881956611106672985015071877198253568414405109"
        ];
        let scalar = "48439561293906451759052585252797914202762949526041747995844080717082404635286";
        
        for(var i = 0; i < testData.length; i++) {

            let multiply = await instance.multiplyScalar(data.generator[0], data.generator[1], testData[i].scalar);
            let x = BigNumber(multiply[0]);
            let y = BigNumber(multiply[1]);
            assert(x.isEqualTo(BigNumber(testData[i].result[0])) && y.isEqualTo(BigNumber(testData[i].result[1])), 
                "The scalar " + testData[i].scalar + " does not yield the expected result");
        }

    });
    
    
});