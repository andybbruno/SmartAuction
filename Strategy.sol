pragma solidity ^ 0.5.1;

contract Strategy {
    function getPrice(uint _actualPrice, uint _deltaBlocks) public view returns(uint);
}

contract NormalStrategy is Strategy {
    function getPrice(uint _actualPrice, uint _deltaBlocks) public view returns(uint) {
        uint tmp = _actualPrice - _deltaBlocks;

        //in case of underflow
        if (tmp > _actualPrice) return 0;
        else return tmp;
    }
}

contract FastStrategy is Strategy {
    function getPrice(uint _actualPrice, uint _deltaBlocks) public view returns(uint) {
        uint tmp = _actualPrice - (2 * _deltaBlocks);

        //in case of underflow
        if (tmp > _actualPrice) return 0;
        else return tmp;
    }
}

contract SlowStrategy is Strategy {
    function getPrice(uint _actualPrice, uint _deltaBlocks) public view returns(uint) {
        uint tmp = _actualPrice - (_deltaBlocks / 2);

        //in case of underflow
        if (tmp > _actualPrice) return 0;
        else return tmp;
    }
}
