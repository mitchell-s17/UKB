-------------------

# initialise session

dx run app-cloud_workstation --ssh -y -imax_session_length=4h

# file id's for reference 

ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bed	----	file-GvZz568Jp2pxF6X7f80ypZjj
ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bim	----	file-GvZyFG8Jp2pvKJx7ZXvzGvjZ
ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.fam	----	file-GvVgF58Jp2ppzX5VZ3jxKX1z
HTN_wes_200k.phe                                            	----	file-GxQZv2jJp2pf0Y2p25J1BzG8
HTN_wes_500k.phe										----	file-Gxj2J9jJp2pVqjFXk412Qxkv

-------------------
# part B merge complete [not required]
-------------------

# PART C

# edit: nano 02-step1-qc-filter.sh
# run with: sh 02-step1-qc-filter.sh

#!/bin/sh

# Set output directory
data_file_dir="/CRCh38"


# Define the PLINK command
run_plink_qc="plink2 --bfile ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged\
 --keep HTN_wes_500k.phe --autosome \
 --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 \
 --mind 0.1 --write-snplist --write-samples \
 --no-id-header --out HTN_WES500k_array_snps_qc_pass"

#SAK 
dx run swiss-army-knife \
   -iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bed" \
   -iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bim" \
   -iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.fam" \
   -iin="${data_file_dir}/HTN_wes_500k.phe" \
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" \
   --destination="${data_file_dir}" --brief --yes

------------------
# PART D

# edit with nano partD-step1-qc-regenie.sh
# Run this shell script using: 
# sh partD-step1-qc-regenie.sh
	
#!/bin/sh

data_file_dir="/CRCh38"

#REGENIE Step 1 command 
run_regenie_step1="regenie --step 1 --lowmem --out HTN_results --bed ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged --phenoFile HTN_wes_500k.phe --covarFile HTN_wes_500k.phe --extract HTN_WES500k_array_snps_qc_pass.snplist --phenoCol HTN_cc --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked --bsize 1000 --bt --loocv --gz --threads 16"

#SAK
dx run swiss-army-knife \
	-iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bed" \
	-iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.fam" \
	-iin="${data_file_dir}/ukb_c1-22_GRCh38_full_analysis_set_plus_decoy_hla_merged.bim"\
	-iin="${data_file_dir}/HTN_WES500k_array_snps_qc_pass.snplist" \
	-iin="${data_file_dir}/HTN_wes_500k.phe" \
	-icmd="${run_regenie_step1}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
	--destination="${data_file_dir}" --brief --yes
	
	
-----------------------------------------------

# PART E

# set to directory (PLINK files)
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - final release"

# set to exome field for fields 
data_field="ukb23158"
data_file_dir="/CRCh38"

for chr in {1..22}; do run_plink_wes="plink2 --bfile ${data_field}_c${chr}_b0_v1 --no-pheno --keep HTN_wes_500k.phe --autosome --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 --mind 0.1 --write-snplist --write-samples --no-id-header --out HTN_WES500k_c${chr}_snps_qc_pass"; 
dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bed" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bim" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.fam" -iin="${data_file_dir}/HTN_wes_500k.phe" -icmd="${run_plink_wes}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16" --destination="${data_file_dir}" --brief --yes
done

-------------------------------------------------

# PART F

#!/bin/bash

# Run this shell script using: 
#   sh partF-step2-regenie.sh 

#change exome_file_dir and data_field for the newest release
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - final release"
data_field="ukb23158"
data_file_dir="/CRCh38"

for chr in {1..22}; do
  run_regenie_cmd="regenie --step 2 --bed ${data_field}_c${chr}_b0_v1 --out HTN500k_assoc.c${chr}\
    --phenoFile HTN_wes_500k.phe --covarFile HTN_wes_500k.phe\
    --bt --approx --firth-se --firth --extract HTN_WES500k_c${chr}_snps_qc_pass.snplist\
    --phenoCol HTN_cc --covarCol age --covarCol sex --covarCol ethnic_group --covarCol ever_smoked \
    --pred HTN_results_pred.list --bsize 200\
    --pThresh 0.05 --minMAC 3 --threads 16 --gz"

  dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bed" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.bim" -iin="${exome_file_dir}/${data_field}_c${chr}_b0_v1.fam" -iin="${data_file_dir}/HTN_WES500k_c${chr}_snps_qc_pass.snplist" -iin="${data_file_dir}/HTN_wes_500k.phe" -iin="${data_file_dir}/HTN_results_pred.list" -iin="${data_file_dir}/HTN_results_1.loco.gz" -icmd="${run_regenie_cmd}" --tag="Step2" --instance-type "mem1_ssd1_v2_x16" --destination="${data_file_dir}" --brief --yes
done

---------------------------

# PART G 


dx run swiss-army-knife \
  -iin="/${data_file_dir}/HTN500k_assoc.c1_HTN_cc.regenie.gz" \
  -icmd='
out_file="HTN500k_assoc.regenie.merged.txt"

# Use dxFUSE to copy the regenie files into the container storage
cp /mnt/project/CRCh38/*.regenie.gz .
gunzip *.regenie.gz

# add the header back to the top of the merged file
echo -e "CHROM\tGENPOS\tID\tALLELE0\tALLELE1\tA1FREQ\tN\tTEST\tBETA\tSE\tCHISQ\tLOG10P\tEXTRA" > $out_file
files="./*.regenie"
for f in $files
do
   tail -n+2 "$f" | tr " " "\t" >> $out_file
done

# remove regenie files
rm *.regenie
' \
  --tag="Step1" \
  --instance-type "mem1_ssd1_v2_x16" \
  --destination="${data_file_dir}" \
  --brief --yes






