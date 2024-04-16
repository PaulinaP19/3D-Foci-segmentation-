//written by Paulina Prorok for MB10 2023/24
//ImageJ macro to deconvolve farred and green channels and save deconvolved images

//########################
macro "Deconvolve & select mid plane" 
	{
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Results Directory ");

	
	list = getFileList(dir1);
	
	for (i=0; i<list.length; i++)
		{
		if (endsWith(list[i], ".tif"))
			{
			filename = dir1 + list[i];
			imagename = list[i];
			
			setBatchMode(true);
			open(filename);
			rename("image");
			
			
			run("Split Channels");
			selectWindow("C4-image");
			rename("DAPI");
			
			selectWindow("C3-image");
			rename("rawGreen");
			selectWindow("C2-image");
			rename("rawRed");
			
			selectWindow("C1-image");
			rename("rawAF647");
			
			
			
			// Deconvolution
			open(dir1+"PSF_488_SPE_63x.tiff");
			rename("PFSgreen");
			open(dir1+"PSF_635_SPE_63x.tiff");
			rename("PFSfarRed");

			run("Iterative Deconvolve 3D", "image=[rawGreen] point=PFSgreen output=Deconvolved normalize show log perform detect wiener=0.000 low=1 z_direction=1 maximum=5 terminate=0.010");
			rename("deconvGreen");	
			run("8-bit");	
			run("Set Scale...", "distance=1 known=0.08542 unit=µm");
		
			
			run("Iterative Deconvolve 3D", "image=[rawAF647] point=PFSfarRed output=Deconvolved normalize show log perform detect wiener=0.000 low=1 z_direction=1 maximum=5 terminate=0.010");
			rename("deconvAF647");	
			run("8-bit");
			run("Set Scale...", "distance=1 known=0.08542 unit=µm");
	
			

			
			// Merge deconvolved stack image
			run("Merge Channels...", "c1=rawRed c2=deconvGreen c3=DAPI c6=deconvAF647 keep create");
	
			run("Arrange Channels...", "new=4123");
			saveAs("Tiff", dir2 + imagename + "-deconv.tif");
			

			close('*');
			
			
			}
		}
	}


			