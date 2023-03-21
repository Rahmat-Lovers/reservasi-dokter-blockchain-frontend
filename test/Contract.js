import { expect } from "chai"
import hre from "hardhat"

describe('Contract', async () => {
    it("Cek", async () => {
        const Contract = await hre.ethers.getContractFactory("Contract")
        const contract = await Contract.deploy('0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199')

        const signer_admin = await hre.ethers.getSigner(19)
        const signer_buyer = await hre.ethers.getSigner(1)
        const signer_seller = await hre.ethers.getSigner(2)

        const contract_admin = await hre.ethers.getContractAt("Contract", contract.address, signer_admin)
        const contract_buyer = await hre.ethers.getContractAt("Contract", contract.address, signer_buyer)
        const contract_seller = await hre.ethers.getContractAt("Contract", contract.address, signer_seller)

        const trx = await contract_buyer.create("salis", await signer_buyer.getAddress(), await signer_seller.getAddress(), hre.ethers.utils.parseEther('1'))
        await contract_buyer.pay("salis", {
            value: hre.ethers.utils.parseEther('1')
        })
        await contract_admin.cancel("salis")

        console.log(await signer_seller.getBalance())
        console.log(await signer_buyer.getBalance())
    })
})