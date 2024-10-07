// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DecentralizedExchange {
    struct LiquidityPool {
        uint256 tokenA;
        uint256 tokenB;
        uint256 totalLiquidity;
        mapping(address => uint256) liquidityShare;
    }

    LiquidityPool public pool;

    uint256 public feePercent = 3;

    event LiquidityAdded(address indexed provider, uint256 tokenAAmount, uint256 tokenBAmount);
    event LiquidityRemoved(address indexed provider, uint256 tokenAAmount, uint256 tokenBAmount);
    event TokensSwapped(address indexed trader, uint256 tokenAOut, uint256 tokenBIn, uint256 fee);

    function addLiquidity(uint256 _tokenAAmount, uint256 _tokenBAmount) external {
        pool.tokenA += _tokenAAmount;
        pool.tokenB += _tokenBAmount;
        uint256 liquidity = _tokenAAmount + _tokenBAmount;
        pool.totalLiquidity += liquidity;
        pool.liquidityShare[msg.sender] += liquidity;

        emit LiquidityAdded(msg.sender, _tokenAAmount, _tokenBAmount);
    }

    function removeLiquidity(uint256 _amount) external {
        require(pool.liquidityShare[msg.sender] >= _amount, "Not enough liquidity");
        uint256 tokenAAmount = (_amount * pool.tokenA) / pool.totalLiquidity;
        uint256 tokenBAmount = (_amount * pool.tokenB) / pool.totalLiquidity;

        pool.tokenA -= tokenAAmount;
        pool.tokenB -= tokenBAmount;
        pool.totalLiquidity -= _amount;
        pool.liquidityShare[msg.sender] -= _amount;

        emit LiquidityRemoved(msg.sender, tokenAAmount, tokenBAmount);
    }

    function swapTokens(uint256 _tokenAIn) external {
        require(_tokenAIn > 0, "Invalid input amount");

        uint256 tokenAOut = (_tokenAIn * pool.tokenB) / (pool.tokenA + _tokenAIn);
        uint256 fee = (tokenAOut * feePercent) / 100;
        uint256 tokenAOutAfterFee = tokenAOut - fee;

        pool.tokenA += _tokenAIn;
        pool.tokenB -= tokenAOutAfterFee;

        emit TokensSwapped(msg.sender, tokenAOutAfterFee, _tokenAIn, fee);
    }

    function getLiquidityShare(address _provider) public view returns (uint256) {
        return pool.liquidityShare[_provider];
    }

    function getPoolDetails() public view returns (uint256, uint256, uint256) {
        return (pool.tokenA, pool.tokenB, pool.totalLiquidity);
    }
}
