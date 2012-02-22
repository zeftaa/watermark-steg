%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E_MOD -- embed a watermark using modulo 256 addition                     
%                                                                          
% Arguments:                                                               
%   im -- image to be watermarked (changed in place)                        
%   m -- one-bit message to embed                                          
%   alpha -- embedding strength                                                    
%                                                                          
% Return value:                                                            
%   im_res -- resulting image                                                                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im_res = e_mod(im, m, alpha)
    % Get width, height 
    [w,h] = size(im);
    
    % Reference pattern (width x height array)   
    wr = rand(w, h)*2-1;
    
    tm = mean2(wr);
    wr = wr-tm;
    
    % Normalized pattern
    st_dev = std2(wr);
    wr = wr/st_dev;
    
    % Encode a one-bit message by either copying or negating the reference pattern
    if (m == 0)
        wm = - wr;
    else
        wm = wr;
    end
    
    % Scale the message pattern by alpha and add it to the image,
    % modulo 256 (NOTE: the scaled reference pattern is rounded to an
    % integer before adding) 
    im_res = double(im) + mod(floor(alpha*wm + 0.5), 256);
    