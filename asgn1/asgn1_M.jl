
ENV["MPLBACKEND"]="tkagg"
using PyPlot
using Statistics
using Distributions
pygui(true)

function load_data()
    
    i0_path = string(@__DIR__,"/skeleton/i0.png")
    i0 = imread(i0_path)
    i0 = convert_to_grayscale(i0)
    i1_path = string(@__DIR__,"/skeleton/i1.png")
    i1 = imread(i1_path)
    i1 = convert_to_grayscale(i1)
    gt_path = string(@__DIR__,"/skeleton/gt.png")
    gt64 = convert(Array{Float64,2}, imread(gt_path)*255)

    @assert maximum(gt64) <= 16
    return i0::Array{Float64,2}, i1::Array{Float64,2}, gt64::Array{Float64,2}
end

#function convert_to_grayscale(image)
#    gray_image = zeros(Float64,(size(image)[1],size(image)[2]))
#    for i = 1:size(image)[1]
#        for j = 1:size(image)[2]
#            gray_image[i, j] = mean(image[i, j, :])
#        end
#    end
#    return gray_image
#end

function convert_to_grayscale(I::Array{Float32,3})
    I=convert(Array{Float64,3}, I)
    I_gray = 0.2989*I[:,:,1] + 0.5870*I[:,:,2] + 0.1140*I[:,:,3]
    return I_gray::Array{Float64,2}
end


# Shift all pixels of i1 to the right by the value of gt
function shift_disparity(i1::Array{Float64,2}, gt::Array{Float64,2})
    
    if !(size(i1) == size(gt))
        print("Disparity map size does not match image size.\n")
    end
    id = zeros(Float64, size(i1))
    #iterating over the columns
    for a = 1:size(i1)[1]
        #iterating over rows
        for b = 1:size(i1)[2]
            id[a, b + convert(Int64, gt[a, b])] = i1[a, b]
        end
    end
    
    
    @assert size(id) == size(i1)
    return id::Array{Float64,2}
end


# Crop image to the size of the non-zero elements of gt
function crop_image(i::Array{Float64,2}, gt::Array{Float64,2})
    a = 1
    b = 1
    while gt[a,convert(Int64,size(gt)[2]/2)] == 0
        a+=1
        
    end
    
    while gt[convert(Int64,size(gt)[1]/2),b] == 0
        b+=1
        
    end
    
    ic= copy(i[a:size(i)[1]-a,b:size(i)[2]-b])

    return ic::Array{Float64,2}
end

function make_noise(i::Array{Float64,2}, noise_level::Float64)
    
    i_noise = copy(i)    
    
    arr=[]
    
    
    totalpx=(size(i)[1])*(size(i)[2])    
    while ((size(arr)[1])/totalpx)<noise_level        
                
        push!(arr,[rand(1:size(i)[1]),rand(1:size(i)[2])])
        arr = unique(arr)
    end
    
    println(((size(arr)[1])/totalpx))
    for p in arr
        i_noise[p[1],p[2]]=rand()*0.8+0.1
    end
    @assert size(i_noise) == size(i)
    
    return i_noise::Array{Float64,2}
end


# Compute the gaussian likelihood by multiplying the probabilities of a gaussian distribution
# with the given parameters for all pixels
function gaussian_lh(i0::Array{Float64,2}, i1::Array{Float64,2}, mu::Float64, sigma::Float64)
    
    gauss = Normal(mu, sigma)
    l = 1
    for a = 1:size(i0)[1]
        for b = 1:size(i0)[2]
            l = l * pdf(gauss, (i0[a, b]-i1[a, b]))
        end
    end
    


    return l::Float64
end


# Compute the negative logarithmic gaussian likelihood in log domain
function gaussian_nllh(i0::Array{Float64,2}, i1::Array{Float64,2}, mu::Float64, sigma::Float64)
    
    gauss = Normal(mu, sigma)
    sum = 0
    for a = 1:size(i0)[1]
        for b = 1:size(i0)[2]
            sum = sum + log(pdf(gauss, (i0[a, b]-i1[a, b])))
        end
    end
    nll= -sum


    return nll::Float64
end


# Compute the negative logarithmic laplacian likelihood in log domain
function laplacian_nllh(i0::Array{Float64,2}, i1::Array{Float64,2}, mu::Float64, s::Float64)
    function lap(x, mu, s)
        y =
        return y
    end
    sum = 0
    for a = 1:size(i0)[1]
        for b = 1:size(i0)[2]
            sum = sum + log((1/2*s)*exp(-abs(i0[a, b]-i1[a, b]-mu)/s))
        end
    end
    nll= -sum
    

    return nll::Float64
end


function problem4()
    # implemented me..
end


p1,p2,dm=load_data()

shifted=shift_disparity(p1,dm)
imshow(crop_image(shifted,dm),"gray")


np=make_noise(p1,0.1)

imshow(np,"gray")
