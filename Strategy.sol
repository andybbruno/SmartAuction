pragma solidity ^0.5.1;

interface PriceStrategy{
    function decrease() external returns (uint);
}

contract Strategy {
    uint initialPrice;
    uint counter;
    
    constructor(uint _initialPrice) public {
        require(_initialPrice > 1);
        initialPrice = _initialPrice;
        counter = 0;
    }
}

contract NormalStrategy is Strategy, PriceStrategy {
    constructor (uint initPrice) Strategy(initPrice) public {}
    
    function decrease() external returns (uint) {
        counter++;
        return initialPrice - counter;
    }
}

contract FastStrategy is Strategy, PriceStrategy {
    constructor (uint initPrice) Strategy(initPrice) public {}
    
    function decrease() external returns (uint) {
        counter++;
        return initialPrice - ((counter**2) / 2);
    }
}

contract VeryFastStrategy is Strategy, PriceStrategy {
    constructor (uint initPrice) Strategy(initPrice) public {}
    
    function decrease() external returns (uint) {
        counter++;
        return initialPrice - ((counter**3) / 2);
    }
}

contract SlowStrategy is Strategy, PriceStrategy {
    constructor (uint initPrice) Strategy(initPrice) public {}
    
    function decrease() external returns (uint) {
        counter++;
        return initialPrice - (3 * counter / 5);
    }
}

contract VerySlowStrategy is Strategy, PriceStrategy {
    constructor (uint initPrice) Strategy(initPrice) public {}
    
    function decrease() external returns (uint) {
        counter++;
        return initialPrice - (2 * counter / 5);
    }
}



