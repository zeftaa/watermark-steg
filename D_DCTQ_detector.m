%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D_DCTQ -- determine whether or not an image is authentic using a
%           semi-fragile watermark based on DCT quantization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DCT Coefficients used to embed a semi-fragile watermark 
coefs = [                  15 ...
                        22 23 ...
                     29 30 31 ...
                  36 37 38 39 ...
               43 44 45 46 47 ...
            50 51 52 53 54 55 ...
         57 58 59 60 61 62 63];
  
% Quantization table    
Qt = [16  11  10  16  24  40  51  61 ...
      12  12  14  19  26  58  60  55 ...
      14  13  16  24  40  57  69  56 ... 
      14  17  22  29  51  87  80  62 ...
      18  22  37  56  68 109 103  77 ...
      24  35  55  64  81 104 113  92 ...
      49  64  78  87 103 121 120 101 ...
      72  92  95  98 112 100 103 99];

% Initialize internal random number generator
% (same initial state as the embeder; synchronized)
seed = hex2dec('dc7533d');
rng(seed);

% Multiplier for quantization matrix
alpha = 0.3;

% Threshhold for matching bits
tm = 80;

% Read original images
base_im_dir = 'images';
im_files = {'fish', 'jump', 'lena', 'plane', 'sea'};

for im_idx = 1:length(im_files)
    curr_im = strcat(base_im_dir, '\', im_files{im_idx}, '_e_dctq.bmp');
    
    im_in = imread(curr_im);
    [w, h] = size(im_in);
    
    % Maximum number of bits that could be matched
    % (actual number is lower because possibly not all bits have been embeded)
    total = w/8 * h/8 * 4;

    % Extract 4 bits from the high-frequency DCT coefficients of each 8 x 8
    % block in the image
    delta = 0;
    for i=1:w/8
        for j=1:h/8
            % 8x8 block to be embeded in
            block = im_in((i-1)*8+1: i*8, (j-1)*8+1: j*8);
            
            % Generate 4 random bits to compare with
            % (! the same as the ones generated by the embeder)
            bits = round(rand(1,4));
            
            % Randomize the array of the 28 coefficients
            % (! same coefficients as the ones from embeder)
            coefs = coefs(randperm(length(coefs)));
            
            % Extracted bits
            out_bits = ExtractDCTQWmkFromOneBlock(reshape(block, 1, 8*8), coefs, alpha*Qt);
            
            % Compute difference
            for idx = 1: 4
                if (bits(idx) ~= out_bits(idx))
                    delta = delta + 1;
                end
            end
        end
    end
    
    % Percent of matching bits
    p_match = (total-delta)/total*100;
    fprintf('Maximum possible bits in %s:  %d. Different : %d. Matched: %2.3f%%. ', ...
        char(strcat(im_files(im_idx), '.bmp')), total, delta, p_match);
    if (p_match>tm)
        fprintf('Authentic.\n');
    else
        fprintf('Not authentic.\n');
    end
end

