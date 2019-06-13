pragma solidity ^0.5.0;

// import "./Helper.sol";

contract Sha512 {

	function  bitsLength(byte b) pure public returns(uint) {
		uint length = 0;
		uint tempI = uint(uint8(b));
		while (tempI != 0) { 
			tempI >>= 1; 
			length++; 
		}
		return length;
	}

	function bytesLength(bytes memory message) pure public returns(uint){
		uint length = 0;
		uint aux;
		for(uint i = 0; i < message.length; i++){
			aux = bitsLength(message[i]);
			length += aux ;
			if(length > 0 && aux == 0){
				length += 8;
			}
		}
		return length;	
	}

	function preprocess(bytes memory message) 
		pure 
		public 
		// returns(uint)
		returns(bytes memory)
	{
		bytes memory result = new bytes(message.length);

		for(uint i = 0; i < message.length; i++){
			result[i] = message[i] << 1;
		}

		result[result.length - 1] = result[result.length - 1] | 0x01;

		uint zeroPadding = 960 - (bytesLength(result) % 512);
		uint number_of_bytes  = zeroPadding / 8;
		uint number_of_shifts = zeroPadding % 8;

		if (number_of_shifts > 0){
			number_of_bytes += 1;
		}

		bytes memory resultWithZeros = new bytes(result.length + number_of_bytes);
		for(uint i = 0; i < result.length; i++){
			resultWithZeros[i] = result[i];
		}

		bytes memory resultWithSize = new bytes(resultWithZeros.length + 8);
		for(uint i = 0; i < resultWithZeros.length; i++){
			resultWithSize[i] = resultWithZeros[i];
		}

		uint messageLength = message.length;

		resultWithSize[resultWithSize.length - 8] = bytes1(uint8(messageLength >> 8**7));
		resultWithSize[resultWithSize.length - 7] = bytes1(uint8(messageLength >> 8**6));
		resultWithSize[resultWithSize.length - 6] = bytes1(uint8(messageLength >> 8**5));
		resultWithSize[resultWithSize.length - 5] = bytes1(uint8(messageLength >> 8**4));
		resultWithSize[resultWithSize.length - 4] = bytes1(uint8(messageLength >> 8**3));
		resultWithSize[resultWithSize.length - 3] = bytes1(uint8(messageLength >> 8**2));
		resultWithSize[resultWithSize.length - 2] = bytes1(uint8(messageLength >> 8));
		resultWithSize[resultWithSize.length - 1] = bytes1(uint8(messageLength));

		return resultWithSize;
		// return bytesLength(resultWithSize);
		// return bytesLength(resultWithSize) % 512;
	}	

	function bytesToUint64(bytes memory data, uint begin) public pure returns (uint64){
        uint number = 0;
        for(uint i = 0; i < 8; i++){
        	number += uint(uint8(data[begin + i])) * 8**(7 - i);
        }
        return uint64(number);
    }

	function getBlock(bytes memory data, uint number) public pure returns(uint64[16] memory)
	{
		uint64[16] memory response;
		uint blockNumber = 128*number;
		for(uint i = 0; i < 16; i++){
			response[i] = bytesToUint64(data, blockNumber + 8*i);	
		}
		return response;
	}

	function rotateL(uint64 data, uint digits) public pure returns(uint64){
		uint quoc = data / 2**digits;
		return uint64((data << digits) + quoc);
	}

	function rotateR(uint64 data, uint digits) public pure returns(uint64){
		uint rest = data % 2**digits;
		return uint64(rest * 2**(64 - digits) + (data >> digits));
	}

	function digest(bytes memory data) 
		public 
		pure 
		returns(uint64[8] memory)
	{
		bytes memory blocks = preprocess(data);
		
		uint64[8]  memory h;
		uint64[80] memory k;
		uint64[8]  memory funcVar; // Funcional Vars

		uint64 s0;
		uint64 s1;
		uint64 ch;
		uint64 maj;
		uint64 temp1;
		uint64 temp2;

		// uint number_of_blocks = blocks.length/64;
		uint64[16] memory dataBlocks = getBlock(blocks, 0);
		uint64[80] memory w;

		h[0] = 0x6A09E667F3BCC908;
		h[1] = 0xBB67AE8584CAA73B;
		h[2] = 0x3C6EF372FE94F82B;
		h[3] = 0xA54FF53A5F1D36F1;
		h[4] = 0x510E527FADE682D1;
		h[5] = 0x9B05688C2B3E6C1F;
		h[6] = 0x1F83D9ABFB41BD6B;
		h[7] = 0x5BE0CD19137E2179;

		k[ 0] = 0x428a2f98d728ae22;
		k[ 1] = 0x7137449123ef65cd;
		k[ 2] = 0xb5c0fbcfec4d3b2f;
		k[ 3] = 0xe9b5dba58189dbbc;
		k[ 4] = 0x3956c25bf348b538;
		k[ 5] = 0x59f111f1b605d019;
		k[ 6] = 0x923f82a4af194f9b;
		k[ 7] = 0xab1c5ed5da6d8118;
		k[ 8] = 0xd807aa98a3030242;
		k[ 9] = 0x12835b0145706fbe;
		k[10] = 0x243185be4ee4b28c;
		k[11] = 0x550c7dc3d5ffb4e2;
		k[12] = 0x72be5d74f27b896f;
		k[13] = 0x80deb1fe3b1696b1;
		k[14] = 0x9bdc06a725c71235;
		k[15] = 0xc19bf174cf692694;
		k[16] = 0xe49b69c19ef14ad2;
		k[17] = 0xefbe4786384f25e3;
		k[18] = 0x0fc19dc68b8cd5b5;
		k[19] = 0x240ca1cc77ac9c65;
		k[20] = 0x2de92c6f592b0275;
		k[21] = 0x4a7484aa6ea6e483;
		k[22] = 0x5cb0a9dcbd41fbd4;
		k[23] = 0x76f988da831153b5;
		k[24] = 0x983e5152ee66dfab;
		k[25] = 0xa831c66d2db43210;
		k[26] = 0xb00327c898fb213f;
		k[27] = 0xbf597fc7beef0ee4;
		k[28] = 0xc6e00bf33da88fc2;
		k[29] = 0xd5a79147930aa725;
		k[30] = 0x06ca6351e003826f;
		k[31] = 0x142929670a0e6e70;
		k[32] = 0x27b70a8546d22ffc;
		k[33] = 0x2e1b21385c26c926;
		k[34] = 0x4d2c6dfc5ac42aed;
		k[35] = 0x53380d139d95b3df;
		k[36] = 0x650a73548baf63de;
		k[37] = 0x766a0abb3c77b2a8;
		k[38] = 0x81c2c92e47edaee6;
		k[39] = 0x92722c851482353b;
		k[40] = 0xa2bfe8a14cf10364;
		k[41] = 0xa81a664bbc423001;
		k[42] = 0xc24b8b70d0f89791;
		k[43] = 0xc76c51a30654be30;
		k[44] = 0xd192e819d6ef5218;
		k[45] = 0xd69906245565a910;
		k[46] = 0xf40e35855771202a;
		k[47] = 0x106aa07032bbd1b8;
		k[48] = 0x19a4c116b8d2d0c8;
		k[49] = 0x1e376c085141ab53;
		k[50] = 0x2748774cdf8eeb99;
		k[51] = 0x34b0bcb5e19b48a8;
		k[52] = 0x391c0cb3c5c95a63;
		k[53] = 0x4ed8aa4ae3418acb;
		k[54] = 0x5b9cca4f7763e373;
		k[55] = 0x682e6ff3d6b2b8a3;
		k[56] = 0x748f82ee5defb2fc;
		k[57] = 0x78a5636f43172f60;
		k[58] = 0x84c87814a1f0ab72;
		k[59] = 0x8cc702081a6439ec;
		k[60] = 0x90befffa23631e28;
		k[61] = 0xa4506cebde82bde9;
		k[62] = 0xbef9a3f7b2c67915;
		k[63] = 0xc67178f2e372532b;
		k[64] = 0xca273eceea26619c;
		k[65] = 0xd186b8c721c0c207;
		k[66] = 0xeada7dd6cde0eb1e;
		k[67] = 0xf57d4f7fee6ed178;
		k[68] = 0x06f067aa72176fba;
		k[69] = 0x0a637dc5a2c898a6;
		k[70] = 0x113f9804bef90dae;
		k[71] = 0x1b710b35131c471b;
		k[72] = 0x28db77f523047d84;
		k[73] = 0x32caab7b40c72493;
		k[74] = 0x3c9ebe0a15c9bebc;
		k[75] = 0x431d67c49c100d4c;
		k[76] = 0x4cc5d4becb3e42b6;
		k[77] = 0x597f299cfc657e2a;
		k[78] = 0x5fcb6fab3ad6faec;
		k[79] = 0x6c44198c4a475817;

		funcVar[0] = h[0];
    	funcVar[1] = h[1];
    	funcVar[2] = h[2];
    	funcVar[3] = h[3];
    	funcVar[4] = h[4];
    	funcVar[5] = h[5];
    	funcVar[6] = h[6];
    	funcVar[7] = h[7];

		for(uint i = 0; i < 16; i++){
			w[i] = dataBlocks[i];
		}

		for(uint i = 16; i < 80; i++){
	    	s0 = rotateR(w[i-15],7) ^ rotateR(w[i-15],18) ^ (w[i-15] >> 3);
	        s1 = rotateR(w[i-2],17) ^ rotateR(w[i-2 ],19) ^ (w[i-2] >> 10);
	        w[i] = w[i-16] + s0 + w[i-7] + s1;
    	}

    	for(uint i = 16; i < 80; i++){
    		s1 = rotateR( funcVar[4],6) ^ rotateR(funcVar[4],11) ^ rotateR(funcVar[4],25);
	        ch = (funcVar[4] &  funcVar[5]) ^ ((~ funcVar[4]) ^ funcVar[6]);
	        temp1 =  funcVar[7] + s1 + ch + k[i] + w[i];
	        s0 = rotateR(funcVar[0],2) ^ rotateR(funcVar[0],13) ^ rotateR(funcVar[0],22);
	        maj = (funcVar[0] &  funcVar[1]) ^ (funcVar[0] &  funcVar[2]) ^ (funcVar[1] &  funcVar[2]);
	        temp2 = s0 + maj;
    	}

    	funcVar[7] = funcVar[6];
        funcVar[6] = funcVar[5];
        funcVar[5] = funcVar[4];
        funcVar[4] = funcVar[3] + temp1;
        funcVar[3] = funcVar[2];
        funcVar[2] = funcVar[1];
        funcVar[1] = funcVar[0];
        funcVar[0] = temp1 + temp2;

     	h[0] = h[0] + funcVar[0];
	    h[1] = h[1] + funcVar[1];
	    h[2] = h[2] + funcVar[2];
	    h[3] = h[3] + funcVar[3];
	    h[4] = h[4] + funcVar[4];
	    h[5] = h[5] + funcVar[5];
	    h[6] = h[6] + funcVar[6];
	    h[7] = h[7] + funcVar[7];

		return h;
	}
	

}