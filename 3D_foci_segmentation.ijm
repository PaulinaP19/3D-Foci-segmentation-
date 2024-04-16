//written by Paulina Prorok for MB10 2023/24
//ImageJ macro to segment EdU and gH2AX foci in Sphase cells using 3D ImageJ Suite
// S phase cells are selected based on the number of EdU local maxima in EdU channel 



macro "Count replication and DNA damage signals" 
	{
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Results Directory ");
	
	// read in file listing from source directory
	list = getFileList(dir1);
	
	
	setBatchMode(true);
	
	
	
	// loop over the files in the source directory
	for (i=0; i<list.length; i++)
		{
			
		if (endsWith(list[i], ".tif"))
			{
			
			filename = dir1 + list[i];
			imagename = list[i];	
			open(filename);	
			rename("image");
			run("Duplicate...", "duplicate");
			rename("AllChannels");
			
			selectWindow("image");
			run("Split Channels");
			selectWindow("C4-image");
			rename("DAPI");
			
	//select 2D slices for cell segmentation 
			slices2 = round(nSlices/2) -2;
			slices3 = round(nSlices/2);
			Stack.setSlice(slices2);
			run("Duplicate...", "use");
			rename("DAPI-mask");
			
			run("Convert to Mask", "method=Huang background=Dark calculate black");
			run("Fill Holes");
			run("Dilate");
			run("Watershed");
			run("Analyze Particles...", "size=130-450 display exclude clear include add");
			
			selectWindow("DAPI-mask");
			
			saveAs("Tiff", dir2 + imagename + "_DAPI-mask.tif");
			close(); 
			
	//select 2D slices for S phase classifiation of cells
	
			selectWindow("C3-image");
			rename("EdUfoci");
			Stack.setSlice(slices3);
			run("Duplicate...", "use");
			rename("EdU_classification");
			
			
			selectWindow("C2-image");
			close();
			
			selectWindow("C1-image");
			rename("gH2AXfoci");
		
			
	//classify cells to S and non S-phase cells  
	
			if (isOpen("Results")){
				selectWindow("Results");
				run("Close");
				selectWindow("EdU_classification");
				
				num=roiManager("count"); 
				NO_Sphase =newArray(num);
				Sphase =newArray(num);
				counter_S = 0;
				counter_NS =0; 
				
				for(l=0; l < num; l++) {
					
					roiManager("select",l); 
					run("Find Maxima...", "prominence=40 output=Count");
					a = getResult("Count", l);
					if (a < 15) {
						
						NO_Sphase[counter_NS] = l;
						counter_NS +=1;
						
					}
					else {
						
						Sphase[counter_S] = l;
						counter_S +=1; 
					}
				}
					
				Sphase = Array.slice(Sphase, 0, counter_S);
				NO_Sphase = Array.slice(NO_Sphase, 0, counter_NS);
					
    //count EdU foci
					
				if (Sphase.length >0) {
				
				
				Sl = Sphase.length;
			    for (k = 0; k < Sl; k++) {
			       selectWindow("AllChannels");
				   roiManager("select",Sphase[k]);
				   run("Enlarge...", "enlarge=1");
				   roiManager("update");
				   run("Duplicate...", "duplicate" );
				   rename("AllChannelsOne");
				   run("Clear Outside", "stack");
				   selectWindow("AllChannelsOne" );
				   saveAs("Tiff", dir2 + imagename + "_allChannels_" + (k+1) + "_cleared.tif");
				   close();
				   selectWindow("EdUfoci");
				   roiManager("select",Sphase[k]);
				   //run("Enlarge...", "enlarge=1");
				   //roiManager("update");
				   run("Duplicate...", "duplicate" );
				   rename("EdUf");
				   run("Clear Outside", "stack");
				   selectWindow("EdUf");
			       run("3D Fast Filters","filter=MaximumLocal radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
			       run("3D Spot Segmentation", "seeds_threshold=30 local_background=0 local_diff=0 radius_0=2 radius_1=4 radius_2=6 weigth=0 radius_max=10 sd_value=1 local_threshold=[Gaussian fit] seg_spot=Maximum watershed volume_min=2 volume_max=1000000 seeds=3D_MaximumLocal spots=EdUf radius_for_seeds=2 output=[Label Image]");
				 
				
				   run("3D Manager");
				   selectWindow("Index");
				   Ext.Manager3D_AddImage();
				  Ext.Manager3D_SelectAll();
				  Ext.Manager3D_Count(nb);
				 
 					if (nb ==0){
 		
        				continue;
    				}
    			   Ext.Manager3D_SelectAll();
	               Ext.Manager3D_Measure();
	          
	               Ext.Manager3D_SaveResult("M", dir2 + imagename + "_EdUfoci_"+ (k+1) +".csv");
	        	   Ext.Manager3D_CloseResult("M");
	               Ext.Manager3D_Quantif();
	               Ext.Manager3D_SaveResult("Q", dir2 + imagename + "INT_EdUfoci_"+(k+1) +".csv");
	               Ext.Manager3D_CloseResult("Q");
	               Ext.Manager3D_SelectAll();
	               Ext.Manager3D_Delete();
	               Ext.Manager3D_Close();
	               selectWindow("3D_MaximumLocal");
			       saveAs("Tiff", dir2 + imagename + "_EdUfoci_" + (k+1)+ ".tif");
			       close();
			       selectWindow("Index");
			       saveAs("Tiff", dir2 + imagename + "_EdUfoci_segmented_" + (k+1) + ".tif");
			       close(); 
			       selectWindow("Log");
			       saveAs("Text", dir2 + imagename+ "_EdUfoci_count_" + (k+1) + ".txt");
			       run("Close");
			       selectWindow("EdUf");
			       saveAs("Tiff", dir2 + imagename + "_EdUfoci_" + (k+1) + "_cropped.tif");
			       close();
			      }
			    	
				
			//count gammeH2AX foci	
			    for (j = 0; j < Sl; j++) {
				   selectWindow("gH2AXfoci");
				   roiManager("select",Sphase[j]);
				   run("Duplicate...", "duplicate" );
				   rename("gH2AXf");
				   run("Clear Outside", "stack");
				   selectWindow("gH2AXf");
			       run("3D Fast Filters","filter=MaximumLocal radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
			       run("3D Spot Segmentation", "seeds_threshold=30 local_background=0 local_diff=0 radius_0=2 radius_1=4 radius_2=6 weigth=0 radius_max=10 sd_value=1 local_threshold=[Gaussian fit] seg_spot=Maximum watershed volume_min=2 volume_max=1000000 seeds=3D_MaximumLocal spots=gH2AXf radius_for_seeds=2 output=[Label Image]");
				  
				  
				   run("3D Manager");
				   selectWindow("Index");
				   Ext.Manager3D_AddImage();
				   Ext.Manager3D_SelectAll();
				    Ext.Manager3D_Count(nb);
				
 					if (nb ==0){
 		
        				continue;
    				}
    			   Ext.Manager3D_SelectAll();
	               Ext.Manager3D_Measure();
	               Ext.Manager3D_SaveResult("M", dir2 + imagename + "_gH2AXfoci_"+ (j+1) +".csv");
	        	   Ext.Manager3D_CloseResult("M");
	               Ext.Manager3D_Quantif();
	               Ext.Manager3D_SaveResult("Q", dir2 + imagename + "INT_gH2AXfoci_"+ (j+1) +".csv");
	               Ext.Manager3D_CloseResult("Q");
	               Ext.Manager3D_SelectAll();
	               Ext.Manager3D_Delete();
	               Ext.Manager3D_Close();
	               selectWindow("3D_MaximumLocal");
			       saveAs("Tiff", dir2 + imagename + "_gH2AXfoci_" + (j+1) +".tif");
			       close();
			       selectWindow("Index");
			       saveAs("Tiff", dir2 + imagename + "_gH2AXfoci_segmented_" + (j+1)+  ".tif");
			       close(); 
			       selectWindow("Log");
			       saveAs("Text", dir2 + imagename+ "_gH2AXfoci_count_" +(j+1) +".txt");
			       run("Close");
			       selectWindow("gH2AXf");
			       saveAs("Tiff", dir2 + imagename + "_gH2AXfoci_" + (j+1) + "_cropped.tif");
			       close();
					
				 }
				 
				
				roiManager("Select All");
				
				roiManager("Save", dir2 + imagename + "_all_cells_roi.zip");
				
				
				roiManager("Delete");
				close("ROI Manager");
				close("*");
				
				}
				else{
					close("ROI Manager");
					close("*");
				
				}
				
			
			else{
				close("*");
				
			}
			
		
	 }
	}
	}