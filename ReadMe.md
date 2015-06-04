# coupledtag
This repository encloses the code for [1], and provide a demo file for computing coupled similarity between images from Flickr.

To run a toy example:  
matlab->  
init;  
toy_example;  

This will show the computed coupled similarity between six objects, with the second attribute being a multi-entry one.  

--------------------------------------------------------------  
*Code details*:  
&nbsp;&nbsp;--coupled algorithm  
&nbsp;&nbsp;&nbsp;&nbsp;--coupled_main: main entrance of the coupled algorithm  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--coupled_IaAVS: intra-coupled similarity  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--coupled_IaAVS_imageF: intra-coupled similarity for image feature  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--coupled_IeAVS_IRSI: inter-coupled similarity  
&nbsp;&nbsp;&nbsp;&nbsp;(--coupled_COS: COS for single-entry features)  
&nbsp;&nbsp;&nbsp;&nbsp;(--coupled_COS_multi: COS for multi-entry features)  
&nbsp;&nbsp;--coupled_CKModes: kmodes clustering  
	
------------------------------------------------------------------  


[1] Z. Xu, Y. Zhang, L. Cao, "Social Image Analysis from a Non-IID Perspective", IEEE Transactions on Multimedia, 16(7):1986-1998, 2014.


