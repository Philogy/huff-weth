// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract ContractTest is Test {
    address constant USER1 = address(uint160(1));
    address constant USER2 = address(uint160(2));
    address constant USER3 = address(uint160(3));
    WETH weth;

    uint256 constant BASE_SUPPLY = 1 ether;

    function setUp() public {
        weth = WETH(payable(HuffDeployer.deploy("WETH")));
        // weth = new WETH();
        vm.label(address(weth), "WETH");

        vm.deal(USER1, 100 ether);

        assertEq(weth.totalSupply(), 0);
        hoax(USER3, 1 ether);
        weth.deposit{value: 1 ether}();
    }

    function testDeploy() public {
        assertEq(weth.totalSupply(), BASE_SUPPLY);
        assertEq(weth.balanceOf(USER1), 0);
        assertEq(weth.allowance(USER1, USER2), 0);
        assertEq(keccak256(abi.encodePacked(weth.symbol())), keccak256("WETH"));
        assertEq(
            keccak256(abi.encodePacked(weth.name())),
            keccak256("Improved Wrapped Ether")
        );
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function testDeposit() public {
        uint256 totalDeposit;

        uint256 depositAmount = 1 ether;
        totalDeposit += depositAmount;
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), USER1, depositAmount);
        vm.prank(USER1);
        weth.deposit{value: depositAmount}();

        assertEq(weth.balanceOf(USER1), totalDeposit);
        assertEq(weth.totalSupply() - BASE_SUPPLY, totalDeposit);

        depositAmount = 2.38 ether;
        totalDeposit += depositAmount;
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), USER1, depositAmount);
        vm.prank(USER1);
        address(weth).call{value: depositAmount}("");

        assertEq(weth.balanceOf(USER1), totalDeposit);
        assertEq(weth.totalSupply() - BASE_SUPPLY, totalDeposit);
    }

    function testTransfer() public {
        vm.prank(USER1);
        uint256 totalDeposit = 50 ether;
        weth.deposit{value: totalDeposit}();

        assertEq(weth.balanceOf(USER1), totalDeposit);

        uint256 transferAmount = 3.18 ether;
        vm.expectEmit(true, true, false, true);
        emit Transfer(USER1, USER2, transferAmount);
        vm.prank(USER1);
        weth.transfer(USER2, transferAmount);
    }
}
