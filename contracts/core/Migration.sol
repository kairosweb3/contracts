// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {INonfungiblePositionManager} from "../univ3-0.8/INonfungiblePositionManager.sol";
import {IUniversalRouter} from "../univ3-0.8/IUniversalRouter.sol";
import {Commands} from "../univ3-0.8/Commands.sol";

import "hardhat/console.sol";

contract Migration is IERC721Receiver {

    INonfungiblePositionManager public immutable nfpm;
    IUniversalRouter public immutable universalRouter;
    address public immutable WEWE; 
    address public immutable WETH;
    address public immutable USDC;

    struct PositionTokens {
        address token0;
        address token1;
    }

    constructor(address _nfpmAddress, address _WEWE, address _WETH, address _universalRouter, address _USDC) {
        nfpm = INonfungiblePositionManager(_nfpmAddress);
        universalRouter = IUniversalRouter(_universalRouter);
        WEWE = _WEWE;
        WETH = _WETH;
        USDC = _USDC;
    }

    function _decreaseAllLiquidityAndCollectFees() private {
    }

    function _swap(address token, uint amount) private {
        bytes memory command = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN)));
        bytes[] memory parameters = new bytes[](1);
        parameters[0] = abi.encode(msg.sender, amount, amount, [token, USDC], true);
        universalRouter.execute(command, parameters, 10);
    }

    function getPositionTokens(uint256 tokenId) internal view returns (PositionTokens memory) {
        ( , , address token0, address token1, , , , , , , , ) = nfpm.positions(tokenId);
        return PositionTokens(token0, token1);
    }

    function isWEWEWETHPool(uint256 tokenId) internal view returns (bool) {
        PositionTokens memory tokens = getPositionTokens(tokenId);
        return (tokens.token0 == WEWE && tokens.token1 == WETH) || (tokens.token0 == WETH && tokens.token1 == WEWE);
        // return false;
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        require(isWEWEWETHPool(tokenId), "Invalid NFT: Not a WEWE-WETH pool token");
        _decreaseAllLiquidityAndCollectFees();
        // _swap();
        return IERC721Receiver.onERC721Received.selector;
    }
}
