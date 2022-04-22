


libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";

options validvarname=V7 ;
options validvarname=upcase;

%macro get_ds(fl=, outds=);
proc import datafile="%sysfunc(pathname(infl,f))/&fl..csv"
     out=&outds.(where=(phases not in ( ' ' 'Not Applicable') and Interventions ne ' ' and status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") ))
     dbms=csv
     replace;
     getnames=yes;
	 guessingrows=32767;
run;
%mend get_ds;

%get_ds(fl=bayer, outds=bay_ct);


/**********STEP 1 - Data Analysis*************/
data bay_ct_;
	set bay_ct(in=a);


	  if substr(strip(upcase(sponsor_collaborators)), 1, 5) = "BAYER" ;

	  SPNSR="BAYER";

	  if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);
run;



proc freq data=bay_ct_ noprint ;
	table Status / list missing out= bay_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=bay_cond;
	table Interventions / list missing out=bay_int;
	table Outcome_Measures / list missing out=bay_out_meas;
	table Phases / list missing out=bay_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=bay_wt;

run;



data bay_ct_da0;
	set bay_ct_;

	/*Conditions*/
	%let MM_cond=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0));

	%let mds_cond = %str(index(upcase(conditions), "MYELODYSPLASTIC SYNDROMES") > 0 or index(upcase(conditions), "MDS") > 0 or 
						 index(upcase(conditions), "MYELODYSPLASTIC") > 0);

	%let aml_cond = %str(index(upcase(conditions), "AML") > 0 or index(upcase(conditions), "MYELOID") > 0 or 
						 index(upcase(conditions), "MYELOGENOUS") > 0);

	%let lym_cond = %str(index(upcase(conditions), "LYMPHOMA") > 0 or index(upcase(conditions), "HODGKIN") > 0 or
						 index(upcase(conditions), "WALDENSTROM'S MACROGLOBULINEMIA") > 0					
						 );

	%let cc_cond = %str(index(upcase(conditions), "CHRONIC LYMPHOCYTIC LEUKEMIA") > 0 or index(upcase(conditions), " LYMPHOCYTIC LEUKEMIA") > 0 or 
						index(upcase(conditions), " LYMPHOCYTIC") > 0 );

	%let leuk_cond = %str(index(upcase(conditions), "LEUKEMIA") > 0 );
 

	%let bd_cond = %str(index(upcase(conditions), "BETA-THALASSEMIA") > 0 or index(upcase(conditions), "THALASSEMIA") > 0 or
						index(upcase(conditions), "HEMOPHILIA") > 0
						);

	%let mf_cond = %str(index(upcase(conditions), "MYELOFIBROSIS") > 0 or index(upcase(conditions), "MF") > 0 );

	%let st_cond = %str( index(upcase(conditions), "SOLID TUMOR") > 0 or index(upcase(conditions), "TUMORS") > 0 or
						 index(upcase(conditions), "BREAST") > 0 or index(upcase(conditions), "LUNG") > 0 or index(upcase(conditions), "NSCLC") > 0 or
						 index(upcase(conditions), "PANCRE") > 0 or index(upcase(conditions), "GASTR") > 0 or index(upcase(conditions), "GLIO") > 0 or
						 index(upcase(conditions), "STOMA") > 0 or index(upcase(conditions), "NEOPLASM") > 0 or index(upcase(conditions), "HEPATOCELLULAR") > 0 or
						 index(upcase(conditions), "ESOPH") > 0 or index(upcase(conditions), "MELANOMA") > 0 or index(upcase(conditions), "BRAIN") > 0 or
						 index(upcase(conditions), "ADVANCED MALIGNANCIES") > 0 or index(upcase(conditions), "ADVANCED CANCER") > 0 or 
						 index(upcase(conditions), "PROSTATE CANCER") > 0 or index(upcase(conditions), "HEAD AND NECK") > 0 or 
						 index(upcase(conditions), "RENAL CELL") > 0 or index(upcase(conditions), "SQUAMOUS CELL CARCINOMA") > 0 or 
						 index(upcase(conditions), "HIGH GRADE SEROUS") > 0 or index(upcase(conditions), "PERITONEAL CANCER") > 0 or 
						 index(upcase(conditions), "MULTIPLE INDICATIONS CANCER") > 0 or index(upcase(conditions), "UROTHELIAL CARCINOMA") > 0 or 
						 index(upcase(conditions), " UROTHELIAL CANCER") > 0 or index(upcase(conditions), "COLORECTAL") > 0 or 
						 index(upcase(conditions), "BLADDER CANCER") > 0 or index(upcase(conditions), "BILIARY TRACT CANCER") > 0 or 
						 index(upcase(conditions), "NASOPHARYNGEAL CARCINOMA") > 0 or index(upcase(conditions), "SALIVARY GLAND CARCINOMA") > 0 or 
						 index(upcase(conditions), "PAN TUMOR") > 0 or index(upcase(conditions), "SOLID CANCERS") > 0 or 
						 index(upcase(conditions), "FALLOPIAN TUBE CANCER") > 0 or index(upcase(conditions), "RECTAL") > 0 or 
						 index(upcase(conditions), "LIVER CANCER") > 0 or index(upcase(conditions), "GENITOURINARY CANCER") > 0 or 
						 index(upcase(conditions), "ADRENOCORTICAL CARCINOMA") > 0 or index(upcase(conditions), "PENILE CANCER") > 0 or 
						 index(upcase(conditions), "MERKEL CELL CARCINOMA") > 0 or index(upcase(conditions), "KIDNEY CANCER") > 0 or
						 index(upcase(conditions), "MESOTHELIOMA") > 0 or index(upcase(conditions), "SARCOMA") > 0 or
						 index(upcase(conditions), "CERVICAL CANCER") > 0 or index(upcase(conditions), "UROTHELIAL CANCER") > 0 or 
						 index(upcase(conditions), "ADVANCED METASTATIC CANCER") > 0 or index(upcase(conditions), "MENINGIOMAS") > 0 or
						 index(upcase(conditions), "RENAL CANCER") > 0 or index(upcase(conditions), "SALIVARY GLAND CANCER") > 0 or
						 index(upcase(conditions), "COLON CARCINOMA") > 0 or index(upcase(conditions), "COLON CANCER") > 0 or
						 index(upcase(conditions), "THYROID CANCER") > 0 or index(upcase(conditions), "LEPTOMENINGEAL CARCINOMATOSIS") > 0 or
						 index(upcase(conditions), "LIP, ORAL CAVITY AND PHARYNX") > 0 or index(upcase(conditions), "CHORDOMA") > 0 or
						 index(upcase(conditions), "ORAL CAVITY SCC") > 0 or compress(upcase(conditions)) = "CANCER" or
						 compress(upcase(conditions)) = "CANCER,NOS" or index(upcase(conditions), "BASAL CELL CARCINOMA") > 0 or
						 index(upcase(conditions), "SCCHN") > 0 or index(upcase(conditions), "LEUKOPLAKIA") > 0 or
						 index(upcase(conditions), "OVARIAN CANCER") > 0 or index(upcase(conditions), "SQUAMOUS CELL") > 0 or 
						 index(upcase(conditions), "HEPATIC CARCINOMA") > 0 or index(upcase(conditions), "PROSTATIC CANCER") > 0 or
						 index(upcase(conditions), "SOLID CANCER") > 0 or index(upcase(conditions), "MIXED TUMOR") > 0 or
						 index(upcase(conditions), "CARCINOMA, TRANSITIONAL CELL") > 0 or index(upcase(conditions), "OVARIAN CARCINOMA") > 0 or 
                         index(upcase(conditions), "CANCER OF THE BILE DUCT") > 0 or index(upcase(conditions), "ADENOID CYSTIC CARCINOMA") > 0
						 );




	%let ii_cond = %str( index(upcase(conditions), "PSORIA") > 0 or index(upcase(conditions), "BEHCET") > 0 or
						 index(upcase(conditions), "SCLERO") > 0 or index(upcase(conditions), "COLITIS") > 0 or index(upcase(conditions), "ULCER") > 0 or
						 index(upcase(conditions), "CROHN") > 0 or index(upcase(conditions), "LUPUS") > 0 or
						 index(upcase(conditions), "LIVER FIBROSIS") > 0 or index(upcase(conditions), "ARTHRITIS") > 0 or
						 index(upcase(conditions), "SJOGREN") > 0 or index(upcase(conditions), "GREN'S SYNDROME") > 0 or 
						 index(upcase(conditions), "HIV") > 0 or index(upcase(conditions), "CHRONIC GRAFT VERSUS HOST DISEASE") > 0 or
						 index(upcase(conditions), "IGG4-RELATED DISEASE") > 0 or index(upcase(conditions), "MYASTHENIA GRAVIS") > 0 or
						 index(upcase(conditions), "MYOSITIS") > 0 or index(upcase(conditions), "POLYMYALGIA RHEUMATICA") > 0 or
						 index(upcase(conditions), "POLYANGIITIS") > 0 or index(upcase(conditions), "GRANULOMATOSIS") > 0 or
						 index(upcase(conditions), "VASCULITIS") > 0 or index(upcase(conditions), "AUTOIMMUNE") > 0 or
						 index(upcase(conditions), "INFLAMMATION") > 0 or index(upcase(conditions), "AMYLOIDOSIS") > 0 or
						 index(upcase(conditions), "TRANSPLANT") > 0 or index(upcase(conditions), "PROTEINURIA") > 0 or
						 index(upcase(conditions), "FAILING RENAL ALLOGRAFT") > 0 or index(upcase(conditions), "ANTIBODY-MEDIATED REJECTION") > 0 or
						 index(upcase(conditions), "LIVER DYSFUNCTION") > 0 or index(upcase(conditions), "RENAL IMPAIRMENT") > 0 or
						 index(upcase(conditions), "GVHD") > 0 or index(upcase(conditions), "DERMATITIS") > 0 or 
						 index(upcase(conditions), "ECZEMA") > 0 or index(upcase(conditions), "LICHEN PLANUS") > 0 or 
						 index(upcase(conditions), "PALMOPLANTARIS PUSTULOSIS") > 0 or index(upcase(conditions), "PULMONARY FIBROSIS") > 0 or
						 index(upcase(conditions), "FRONTAL FIBROSING") > 0 
						);




	%let cv_cond = %str(index(upcase(conditions), "AORTIC") > 0 or index(upcase(conditions), "ARTERY") > 0 or
	                    index(upcase(conditions), "CORONARY") > 0 or index(upcase(conditions), "BYPASS") > 0 or   
						index(upcase(conditions), "GRAFTING") > 0 or index(upcase(conditions), "ATRIAL FIBRILATION") > 0 or  
						index(upcase(conditions), "STROKE") > 0 or index(upcase(conditions), "SYSTEMIC EMBOLISM") > 0 or  
						index(upcase(conditions), "DEEP VENOUS THROMBOSIS") > 0 or index(upcase(conditions), "HEART FAILURE") > 0 or 
						index(upcase(conditions), "THROMBO") > 0 or index(upcase(conditions), "CARDIAC") > 0 or   
						index(upcase(conditions), "MYOCARDIAL") > 0 or index(upcase(conditions), "CONGESTIVE") > 0 or   
						index(upcase(conditions), "HEART") > 0 or index(upcase(conditions), "PROTEINURIA") > 0 or
						index(upcase(conditions), "ATRIAL FIBRILLATION") > 0 or index(upcase(conditions), "PULMONARY EMBOLISM") > 0 or
						index(upcase(conditions), "VENTRICULAR DYSFUNCTION") > 0 or index(upcase(conditions), "VENTRICULAR FAILURE") > 0 or
						index(upcase(conditions), "HYPERTENSION") > 0 or index(upcase(conditions), "KIDNEY DISEASE") > 0
                        );



	if &MM_cond then COND_MM="MULTIPLE MYELOMA";
	if &mds_cond then MDS="MDS";
	if &aml_cond then AML="AML";
	if &lym_cond then LYM="LYMPHOMA";
	if &cc_cond then CLL="CLL";
	if &bd_cond then COND_bt="BLOOD DISORDERS";
	if &mf_cond then MF="MF";
	if &st_cond then COND_ST="SOLID TUMORS";
	if &ii_cond then COND_II="INFLAMMATION & IMMUNOLOGY"; 
	if &cv_cond then COND_CV="CARDIOVASCULAR & KIDNEY DISEASE";
	if &leuk_cond then LEUK="LEUKEMIA";

	if (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) then COND_LL="LEUKEMIA & LYMPHOMA" ;

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' then do;
			put "Sponsor: " SPNSR " & Condition: " conditions " not mapped.";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;



data bay_ct_da;
	set bay_ct_da0;

	/*BAYER Interventions*/
	if index(upcase(Interventions), "BAY94-9027") or index(upcase(compress(Interventions)), "BAY949027") > 0 or
	   index(upcase(Interventions), "BAY94_9027") or index(upcase(compress(Interventions)), "JIVI") > 0 or
	   index(upcase(compress(Interventions)), "DAMOCTOCOG") > 0	then BAY94_9027="BAY94-9027";

	if index(upcase(compress(Interventions)), "BAY88-8223") or index(upcase(compress(Interventions)), "BAY888223") > 0 or
	   index(upcase(Interventions), "BAY88_8223") or index(upcase(compress(Interventions)), "RADIUM-223") > 0 or
	   index(upcase(compress(Interventions)), "RADIUM223") > 0 or index(upcase(compress(Interventions)), "XOFIGO") > 0 or
	   index(upcase(compress(Interventions)), "RA-223") > 0 or index(upcase(compress(Interventions)), "RA223") > 0
	   	then BAY88_8223="RADIUM-223";

	if index(upcase(compress(Interventions)), "BAY63-2521") or index(upcase(compress(Interventions)), "BAY632521") > 0 or
	   index(upcase(Interventions), "BAY63_2521") or index(upcase(compress(Interventions)), "ADEMPAS") > 0 or
	   index(upcase(compress(Interventions)), "RIOCIGUAT") > 0 
	   	then BAY63_2521="ADEMPAS";

	if index(upcase(Interventions), "BAY17-53011") or index(upcase(compress(Interventions)), "BAY1753011") > 0 or
	   index(upcase(Interventions), "BAY17_53011") 
		then BAY17_53011="BAY17-53011";

	if index(upcase(compress(Interventions)), "BAY18-41788") or index(upcase(compress(Interventions)), "BAY1841788") > 0 or
	   index(upcase(Interventions), "BAY18_41788") or index(upcase(compress(Interventions)), "DAROLUTAMIDE") > 0 or
	   index(upcase(compress(Interventions)), "ODM-201") > 0 or index(upcase(compress(Interventions)), "ODM201") > 0 or
	   index(upcase(compress(Interventions)), "DARRAMAMIDE") > 0 or index(upcase(compress(Interventions)), "NUBEQA") > 0
	   	then BAY18_41788="DAROLUTAMIDE";

	if index(upcase(Interventions), "BAY24-33334") or index(upcase(compress(Interventions)), "BAY2433334") > 0 or
	   index(upcase(Interventions), "BAY24_33334") 
		then BAY24_33334="BAY24_33334";

	if index(upcase(Interventions), "BAY25-86116") or index(upcase(compress(Interventions)), "BAY2586116") > 0 or
	   index(upcase(Interventions), "BAY25_86116") 
		then BAY25_86116="BAY25_86116";

	if index(upcase(Interventions), "BAY25-99023") or index(upcase(compress(Interventions)), "BAY2599023") > 0 or
	   index(upcase(Interventions), "BAY25_99023") or index(upcase(compress(Interventions)), "DTX201") > 0
		then BAY25_99023="BAY25_99023";

	if index(upcase(Interventions), "BAY27-31954") or index(upcase(compress(Interventions)), "BAY2731954") > 0 or
	   index(upcase(Interventions), "BAY27_31954") 
		then BAY27_31954="BAY27_31954";

	if index(upcase(compress(Interventions)), "BAY27-57556") or index(upcase(compress(Interventions)), "BAY2757556") > 0 or
	   index(upcase(Interventions), "BAY27_57556") or index(upcase(compress(Interventions)), "LAROTRECTINIB") > 0 or
	   index(upcase(compress(Interventions)), "VITRAKVI") > 0 
	   	then BAY27_57556="LAROTRECTINIB";

	if index(upcase(compress(Interventions)), "BAY73-4506") or index(upcase(compress(Interventions)), "BAY734506") > 0 or
	   index(upcase(Interventions), "BAY73_4506") or index(upcase(compress(Interventions)), "REGORAFENIB") > 0 or
	   index(upcase(compress(Interventions)), "STIVARGA") > 0 
	   	then BAY73_4506="REGORAFENIB";

	if index(upcase(Interventions), "BAY80_6946") or index(upcase(compress(Interventions)), "BAY806946") > 0 or
	   index(upcase(Interventions), "BAY80_6946") 
		then BAY80_6946="BAY80_6946";

	if index(upcase(compress(Interventions)), "BAY94-9343") or index(upcase(compress(Interventions)), "BAY949343") > 0 or
	   index(upcase(Interventions), "BAY94_9343") or index(upcase(compress(Interventions)), "ANETUMAB") > 0 or
	   index(upcase(compress(Interventions)), "RAVTANSINE") > 0 
	   	then BAY94_9343="ANETUMAB";

	if index(upcase(compress(Interventions)), "BAY94-9343") or index(upcase(compress(Interventions)), "BAY949343") > 0 or
	   index(upcase(Interventions), "BAY94_9343") or index(upcase(compress(Interventions)), "ANETUMAB") > 0 or
	   index(upcase(compress(Interventions)), "RAVTANSINE") > 0 
	   	then BAY94_9343="ANETUMAB";

	if index(upcase(compress(Interventions)), "BAY80-6946") or index(upcase(compress(Interventions)), "BAY806946") > 0 or
	   index(upcase(Interventions), "BAY80_6946") or index(upcase(compress(Interventions)), "COPANLISIB") > 0 or
	   index(upcase(compress(Interventions)), "ALIQOPA") > 0 
	   	then BAY80_6946="COPANLISIB";

	if index(upcase(compress(Interventions)), "BAY43-9006") or index(upcase(compress(Interventions)), "BAY439006") > 0 or
	   index(upcase(Interventions), "BAY43_9006") or index(upcase(compress(Interventions)), "SORAFENIB") > 0 or
	   index(upcase(compress(Interventions)), "NEXAVAR") > 0 
	   	then BAY43_9006="SORAFENIB";

	if index(upcase(compress(Interventions)), "BAY94-8862") or index(upcase(compress(Interventions)), "BAY948862") > 0 or
	   index(upcase(Interventions), "BAY94_8862") or index(upcase(compress(Interventions)), "FINERENONE") > 0 
	   	then BAY94_8862="FINERENONE";


	if index(upcase(compress(Interventions)), "BAY86-5028") or index(upcase(compress(Interventions)), "BAY865028") > 0 or
	   index(upcase(Interventions), "BAY86_5028") or index(upcase(compress(Interventions)), "KYLEENA") > 0 or
	   index(upcase(compress(Interventions)), "LEVONORGESTREL") > 0 
	   	then BAY86_5028="LEVONORGESTREL";

	if index(upcase(compress(Interventions)), "BAY86-5131") or index(upcase(compress(Interventions)), "BAY865131") > 0 or
	   index(upcase(Interventions), "BAY86_5131") or index(upcase(compress(Interventions)), "YARINA") > 0 or
	   index(upcase(compress(Interventions)), "DROSPIRENONE") > 0 
	   	then BAY86_5131="DROSPIRENONE";

	if index(upcase(compress(Interventions)), "BAY28-80376") or index(upcase(compress(Interventions)), "BAY2880376") > 0 or
	   index(upcase(Interventions), "BAY28_80376") or index(upcase(compress(Interventions)), "NAPROXEN") > 0 or
	   index(upcase(compress(Interventions)), "ALEVE") > 0 
	   	then BAY28_80376="NAPROXEN";

	if index(upcase(compress(Interventions)), "ORG-538") or index(upcase(compress(Interventions)), "CLR-610") > 0 or
	   index(upcase(Interventions), "TESTOSTERONE") or index(upcase(compress(Interventions)), "NEBIDO") > 0
	   	then BAY_NEBIDO="NEBIDO";

	if index(upcase(compress(Interventions)), "BAY-A2502") or index(upcase(compress(Interventions)), "BAYA2502") > 0 or
	   index(upcase(Interventions), "BAY_A2502") or index(upcase(compress(Interventions)), "NIFURTIMOX") > 0 or
	   index(upcase(compress(Interventions)), "LAMPIT") > 0 
	   	then BAY_A2502="LAMPIT";

	if index(upcase(compress(Interventions)), "BAY59-7939") or index(upcase(compress(Interventions)), "BAY597939") > 0 or
	   index(upcase(Interventions), "BAY59_7939") or index(upcase(compress(Interventions)), "XARELTO") > 0 or
	   index(upcase(compress(Interventions)), "RIVAROXABAN") > 0 
	   	then BAY59_7939="RIVAROXABAN";

	if index(upcase(compress(Interventions)), "BAY10-02670") or index(upcase(compress(Interventions)), "BAY1002670") > 0 or
	   index(upcase(Interventions), "VILAPRISAN") or index(upcase(compress(Interventions)), "BAY10_02670") > 0
	   	then BAY10_02670="VILAPRISAN";

	if index(upcase(compress(Interventions)), "BAY11-63877") or index(upcase(compress(Interventions)), "BAY1163877") > 0 or
	   index(upcase(Interventions), "BAY11_63877") or index(upcase(compress(Interventions)), "ROGARATINIB") > 0
	   	then BAY11_63877="ROGARATINIB";

	if index(upcase(compress(Interventions)), "BAY86-4875") or index(upcase(compress(Interventions)), "BAY864875") > 0 or
	   index(upcase(Interventions), "BAY86_4875") or index(upcase(compress(Interventions)), "GADOBUTROL") > 0
	   	then BAY86_4875="GADOBUTROL";

	if index(upcase(compress(Interventions)), "BAY81-8973") or index(upcase(compress(Interventions)), "BAY818973") > 0 or
	   index(upcase(Interventions), "BAY81_8973") or index(upcase(compress(Interventions)), "KOVALTRY") > 0
	   	then BAY81_8973="KOVALTRY";

	if index(upcase(compress(Interventions)), "IOPROMIDE") or index(upcase(compress(Interventions)), "ULTRAVIST") > 0 
	   	then BAY_IOPROMIDE="IOPROMIDE";


run;



proc contents data=bay_ct_da out=bay_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: bay_cc_int separated by " = ' ' and "
	from bay_ct_cont
	where substr(name,1,3) = "BAY" 
	;
quit;

%put &bay_cc_int. ;

data bay_cc_int_chk;
	set bay_ct_da;
	if &bay_cc_int. = ' ' then do;
		put "Sponsor: " SPNSR " & Condition: " conditions " & Intervention: " interventions " & Phase: " phases " not mapped";
	end;
run;


proc sql noprint ;
	select distinct name into: bay_int_vars separated by '~'
	from bay_ct_cont
	where substr(name,1,3) = "BAY" 
	;
    %let intcnt = &sqlobs;
quit;

%put &BAY_int_vars &intcnt;



proc sql noprint ;
	select distinct name into: bay_cond_vars separated by '~'
	from bay_ct_cont
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &bay_cond_vars &condcnt;






%macro cond_int_ph_wt(anlz_ds=, cond_mvar=, num_cond=, int_mvar=, num_int=);


	%do j =1 %to &condcnt. ;
		%let cond = %scan(&cond_mvar., &j , '~');
		%put Condition = &cond. ;
		    %do i = 1 %to &intcnt. ;
		       %let single = %scan(&int_mvar., &i , '~');
		       %put single = &single;
					proc freq data=&anlz_ds. noprint ;
						   table spnsr*&cond.*&single.*phases  / missing out=__&cond._&single.(where=(&single. ne " " and &cond. ne " " ) 
																					     drop=percent) ;
					run;

					proc sql noprint ;
						select count(&cond.) into: cond_chk_cnt
						from __&cond._&single.
						;
					quit;

					%if &cond_chk_cnt. > 0 %then %do;
						data __&cond._&single.;
							length cond int phases $200.;
							set __&cond._&single.;
								cond=&cond.;
								INT=&single. ;
								drop &cond. &single. ;
						run;
					%end;

					%else %do;
						proc datasets lib=work nolist;
							delete __&cond._&single.;
						quit;
						run;
					%end;
		    %end;
	%end;

%mend cond_int_ph_wt;


%cond_int_ph_wt(anlz_ds=bay_ct_da, cond_mvar=&bay_cond_vars., num_cond=&condcnt., int_mvar=&bay_int_vars., num_int=&intcnt.);


	data all_cond_int_ph;
		length cond int phases $200.;
		set __cond_:;

		*cond1 = strip(put(cond, $condlbl.));
			int  = strip(int);
			phases=strip(phases);

			do i=1 to count;
				output;
			end;
	run;


		



%macro sankey_nodes(inds=all_cond_int_ph, outds=, nodes=%str(spnsr|cond|int|phases), cond=);

	%let cnt = %eval(%sysfunc(countc(&nodes.,"|")) +1);
	%put &cnt.;

	   data _inds;
	   	set &inds.;
		run;

    %do i = 1 %to &cnt;
       %let single&i. = %scan(&nodes, &i , '|');
       %put single&i. = &&single&i;
	%end;


		proc sql;
		    %do i = 1 %to %eval(&cnt. -1);
				create table &&single&i.._wt_chk as
					select distinct 
						%do k=1 %to &i. ;
							&&single&k.,
						%end;
						%superq(single%eval(&i. +1)), &&single&i. as SOURCE length=100,  %superq(single%eval(&i. +1)) as TARGET length=100, count(&&single&i.) as VALUE,	
								"            	{'source':'"||strip(&&single&i.)||"','target':'"||strip(%superq(single%eval(&i. +1)))||"','value':"||strip(put(count(&&single&i.), 5.0))||"}," as final length=1000
					from _inds
					%if &cond. ne %then %do;
						where &cond.
					%end;
					group by 
						%do k=1 %to &i. ;
							&&single&k., 
						%end;
						%superq(single%eval(&i. +1))
					;
			%end;
		quit;


		data &outds.;
			set 
		    %do i = 1 %to %eval(&cnt. -1);
				&&single&i.._wt_chk
			%end;
			;
		run;

		options linesize=max;
		%global sankeydata;

		proc sql noprint;
			select final into: sankeydata separated by " "
			from &outds.
			;
		quit;

		%put &sankeydata. ;

%mend sankey_nodes;

%sankey_nodes(inds=all_cond_int_ph, outds=outds.bayer_sankey, nodes=%str(spnsr|cond|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/bayer.html, width=1900, height=700, flow_num=);



proc datasets lib=work kill memtype=data ;
run;







