----------------------------------

# initialise session
dx run app-cloud_workstation --ssh -y -imax_session_length=4h

# file ids for reference

ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bed ----  file-GvZz568Jp2pxF6X7f80ypZjj
ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bim ----  file-GvZyFG8Jp2pvKJx7ZXvzGvjZ
ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.fam ----  file-GvVgF58Jp2ppzX5VZ3jxKX1z
diabetes_wes_200k.phe                                        ----  file-GxQ8pyQJp2pQg9pkzg5g7G5Q

----------------------------------

# partC-step1-qc-filter 

# edit with: nano 02-step1-qc-filter.sh
# run with: sh 02-step1-qc-filter.sh

#!/bin/sh

	# Set output directory
	data_file_dir="/CRCh38"
	
	
	# Define the PLINK command
	run_plink_qc="plink2 --bfile ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged\
	 --keep diabetes_wes_200k.phe --autosome \
	 --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 \
	 --mind 0.1 --write-snplist --write-samples \
	 --no-id-header --out WES_array_snps_qc_pass"
	
	#SAK 
	dx run swiss-army-knife \
	   -iin="${data_file_dir}/file-GvZz568Jp2pxF6X7f80ypZjj" \
	   -iin="${data_file_dir}/file-GvZyFG8Jp2pvKJx7ZXvzGvjZ" \
	   -iin="${data_file_dir}/file-GvVgF58Jp2ppzX5VZ3jxKX1z" \
	   -iin="${data_file_dir}/file-GxQ8pyQJp2pQg9pkzg5g7G5Q" \
	   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" \
	   --destination="${data_file_dir}" --brief --yes


--------------------------------------------

# partD-step1-regenie

# Run this shell script using: 
# sh partD-step1-qc-regenie.sh

	#!/bin/sh
	
	data_file_dir="/CRCh38"
	
	#REGENIE Step 1 command 
	run_regenie_step1="regenie --step 1 --lowmem --out diabetes_results --bed ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged
	 --phenoFile diabetes_wes_200k.phe --covarFile diabetes_wes_200k.phe 
	 --extract WES_array_snps_qc_pass.snplist --phenoCol diabetes_cc 
	 --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked 
	 --bsize 1000 --bt --loocv --gz --threads 16"
	
	#SAK
	dx run swiss-army-knife \
		-iin="${data_file_dir}/file-GvZz568Jp2pxF6X7f80ypZjj" \
		-iin="${data_file_dir}/file-GvZyFG8Jp2pvKJx7ZXvzGvjZ" \
		-iin="${data_file_dir}/file-GvVgF58Jp2ppzX5VZ3jxKX1z"\
		-iin="${data_file_dir}/file-GxQ8pyQJp2pQg9pkzg5g7G5Q" \
		-icmd="${run_regenie_step1}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
		--destination="${data_file_dir}" --brief --yes
		
	
# SINGLE LINE VERSION [DEBUGGED]
	
	#!/bin/sh
	
	data_file_dir="/CRCh38"
	
	#REGENIE Step 1 command 
	run_regenie_step1="regenie --step 1 --lowmem --out diabetes_results --bed ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged --phenoFile diabetes_wes_200k.phe --covarFile diabetes_wes_200k.phe --extract WES_array_snps_qc_pass.snplist --phenoCol diabetes_cc --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked --bsize 1000 --bt --loocv --gz --threads 16"
	
	#SAK
	dx run swiss-army-knife \
		-iin="${data_file_dir}/file-GvZz568Jp2pxF6X7f80ypZjj" \
		-iin="${data_file_dir}/file-GvZyFG8Jp2pvKJx7ZXvzGvjZ" \
		-iin="${data_file_dir}/file-GvVgF58Jp2ppzX5VZ3jxKX1z"\
		-iin="${data_file_dir}/file-GxQ8pyQJp2pQg9pkzg5g7G5Q" \
		-icmd="${run_regenie_step1}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
		--destination="${data_file_dir}" --brief --yes
		
	
-------------------------------------------------------

# partE-step2-qc-filter

# edit with nano partE-step2-qc-filter.sh
# Run with: sh partE-step2-qc-filter.sh  
 
	#!/bin/bash
	

	#set this to the exome sequence directory that you want (should contain PLINK formatted files)
	exome_file_dir="project-GvV46q0Jp2pfP7yJjvYy8b5y:/Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 200k release"
	
	#set this to the exome data field for your release
	data_field="ukb23155"
	data_file_dir="/CRCh38"
	
	for chr in {1..22}; do
	    run_plink_wes="plink2 --bfile ${exome_file_dir}/${data_field}_c${chr}_b0_v1\
	      --no-pheno --keep diabetes_wes_200k.phe --autosome\
	      --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 --mind 0.1\
	      --write-snplist --write-samples --no-id-header\
	      --out WES_c${chr}_snps_qc_pass"
	
	    dx run swiss-army-knife \
		-iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bed" \
	     -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bim" \
	     -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.fam"\
	     -iin="${data_file_dir}/diabetes_wes_200k.phe" \
	     -iin="${data_file_dir}/file-GvZz568Jp2pxF6X7f80ypZjj" \
	     -icmd="${run_plink_wes}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16"\
	     --destination="${data_file_dir}" --brief --yes
	done




# SINGLE LINE VERSION [DEBUGGED]

	#oneline
	
	#!/bin/bash
	
	exome_file_dir="/Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 200k release"
	data_field="ukb23155"
	data_file_dir="/CRCh38"
	for chr in {1..22}; do run_plink_wes="plink2 --bfile ${data_field}_c${chr}_b0_v1 --no-pheno --keep diabetes_wes_200k.phe --autosome --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 --mind 0.1 --write-snplist --write-samples --no-id-header --out WES_c${chr}_snps_qc_pass"; 
	dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bed" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bim" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.fam" -iin="${data_file_dir}/diabetes_wes_200k.phe" -icmd="${run_plink_wes}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16" --destination="${data_file_dir}" --brief --yes
	done



------------------

# partF-step2-regenie

	#!/bin/bash
	
	# Run with: sh partF-step2-regenie.sh 
	
	#change exome_file_dir and data_field for the newest release
	exome_file_dir="/Bulk/Exome sequences_Previous exome releases/Population level exome OQFE variants, PLINK format - interim 200k release"
	data_field="ukb23155"
	data_file_dir="/CRCh38"
	
	
	for chr in {1..22}; do
	  run_regenie_cmd="regenie --step 2 --bed ${data_field}_c${chr}_b0_v1 --out assoc.c${chr}\
	    --phenoFile diabetes_wes_200k.phe --covarFile diabetes_wes_200k.phe\
	    --bt --approx --firth-se --firth --extract WES_c${chr}_snps_qc_pass.snplist\
	    --phenoCol diabetes_cc --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked \
	    --pred diabetes_results_pred.list --bsize 200\
	    --pThresh 0.05 --minMAC 3 --threads 16 --gz"
	
	  dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bed" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bim" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.fam" -iin="${data_file_dir}/WES_c${chr}_snps_qc_pass.snplist" -iin="${data_file_dir}/diabetes_wes_200k.phe" -iin="${data_file_dir}/diabetes_results_pred.list" -iin="${data_file_dir}/diabetes_results_1.loco.gz" -icmd="${run_regenie_cmd}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16" --destination="${data_file_dir}" --brief --yes
	done


-------------------


# partG-merge-regenie-files

	# run with:  sh partG-merge-regenie-files.sh 


	# Outputs (for each chromosome):
	
	merge_cmd='out_file="assoc.regenie.merged.txt"
	
	# Use dxFUSE to copy the regenie files into the container storage
	cp /mnt/project/CRCh38/*.regenie.gz .
	gunzip *.regenie.gz
	
	# add the header back to the top of the merged file
	echo -e "CHROM\tGENPOS\tID\tALLELE0\tALLELE1\tA1FREQ\tN\tTEST\tBETA\tSE\tCHISQ\tLOG10P\tEXTRA" > $out_file
	
	files="./*.regenie"
	for f in $files
	do
	# for each .regenie file
	# remove header with tail
	# transform to tab delimited with tr
	# save it into $out_file
	   tail -n+2 $f | tr " " "\t" >> $out_file
	done
	
	# remove regenie files
	rm *.regenie'
	
	data_file_dir="/CRCh38"
	
	dx run swiss-army-knife -iin="/${data_file_dir}/assoc.c1_diabetes_cc.regenie.gz" \
	   -icmd="${merge_cmd}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
	   --destination="${data_file_dir}" --brief --yes 








