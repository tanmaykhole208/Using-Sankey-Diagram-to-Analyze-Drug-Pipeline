
libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";



proc format;
	value $condlbl
	"MM"         =	"MULTIPLE MYELOMA"
	"MDS"        =	"MYELODYSPLASTIC SYNDROMES"
	"AML"        =	"ACUTE MYELOID LEUKEMIA"
	"LYMPHOMA"   =	"LYMPHOMA"
	"CLL"        =	"CHRONIC LYMPHOCYTIC LEUKEMIA"
	"B_T"        =	"BETA-THALASSEMIA"
	"MF"         =	"MYELOFIBROSIS"
	"ST"         =	"SOLID TUMORS"  
	"II"  	     =	"INFLAMMATION & IMMUNOLOGY"
	"CV"         =  "CARDIOVASCULAR"
	"LL"         =  "LYMPHOMA & LEUKEMIA"
  ;
run; 


options validvarname=V7;
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

%get_ds(fl=msd, outds=msd_ct);




/**********STEP 1 - Data Analysis*************/
data msd_ct_;
	set msd_ct(in=a);

	  if substr(strip(upcase(sponsor_collaborators)), 1, 3) = "MSD" or substr(strip(upcase(sponsor_collaborators)), 1, 5) = "MERCK" ;

	  SPNSR="MERCK & CO.";

	  if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);
run;



proc freq data=msd_ct_ noprint ;
	table Status / list missing out= msd_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=msd_cond;
	table Interventions / list missing out=msd_int;
	table Outcome_Measures / list missing out=msd_out_meas;
	table Phases / list missing out=msd_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=msd_wt;

run;



data msd_ct_da0;
	set msd_ct_;

	/*Conditions*/
	%let MM_cond=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0));

	%let mds_cond = %str(index(upcase(conditions), "MYELODYSPLASTIC SYNDROMES") > 0 or index(upcase(conditions), "MDS") > 0 or 
						 index(upcase(conditions), "MYELODYSPLASTIC") > 0);

	%let aml_cond = %str(index(upcase(conditions), "AML") > 0 or index(upcase(conditions), "MYELOID") > 0 or 
						 index(upcase(conditions), "MYELOGENOUS") > 0);

	%let lym_cond = %str(index(upcase(conditions), "LYMPHOMA") > 0 or index(upcase(conditions), "HODGKIN") > 0 or
						 index(upcase(conditions), "WALDENSTROM'S MACROGLOBULINEMIA") > 0 or index(upcase(conditions), "WALDENSTROM MACROGLOBULINEMIA") > 0
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
                         index(upcase(conditions), "CANCER OF THE BILE DUCT") > 0 or index(upcase(conditions), "ADENOID CYSTIC CARCINOMA") > 0 or
						 index(upcase(conditions), "BILIARY TRACT CARCINOMA") > 0 or index(upcase(conditions), "PENILE CARCINOMA") > 0 or
						 index(upcase(conditions), "MICROSATELLITE UNSTABLE") > 0 or index(upcase(conditions), "RECURRENT CANCER") > 0 or 
						 index(upcase(conditions), "NASOPHARYNGEAL CANCER") > 0 or index(upcase(conditions), "CANCER OF UNKNOWN") > 0 or
						 index(upcase(conditions), "PENILE CANCER") > 0 or index(upcase(conditions), "ANAL CANCER") > 0 or
						 index(upcase(conditions), "LIVER CARCINOMA") > 0 or index(upcase(conditions), "CARCINOMA, UNSPECIFIED") > 0 or
						 index(upcase(conditions), "CELL CARCINOMA") > 0 or index(upcase(conditions), "MENINGIOMA") > 0 or
						 index(upcase(conditions), "NEUROENDOCRINE CARCINOMA") > 0 or index(upcase(conditions), "ENDOMETRIAL CANCER") > 0 or
						 index(upcase(conditions), "BLADDER CARCINOMA") > 0 or index(upcase(conditions), "SHEATH TUMOUR") > 0 or
						 index(upcase(conditions), "RENAL CARCINOMA") > 0 or index(upcase(conditions), "ADENOCARCINOMA") > 0 
						 );




	%let ii_cond = %str( index(upcase(conditions), "PSORIA") > 0 or index(upcase(conditions), "BEHCET") > 0 or
						 index(upcase(conditions), "SCLERO") > 0 or index(upcase(conditions), "COLITIS") > 0 or index(upcase(conditions), "ULCER") > 0 or
						 index(upcase(conditions), "CROHN") > 0 or index(upcase(conditions), "LUPUS") > 0 or
						 index(upcase(conditions), "LIVER FIBROSIS") > 0 or index(upcase(conditions), "ARTHRITIS") > 0 or
						 index(upcase(conditions), "SJOGREN") > 0 or index(upcase(conditions), "GREN'S SYNDROME") > 0 or 
						 index(upcase(conditions), "CHRONIC GRAFT VERSUS HOST DISEASE") > 0 or
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
						 index(upcase(conditions), "FRONTAL FIBROSING") > 0 or index(upcase(conditions), "INFLAMMAT") > 0 or
						 index(upcase(conditions), "BILIARY CHOLANGITIS") > 0
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
						index(upcase(conditions), "HYPERTENSION") > 0 or index(upcase(conditions), "KIDNEY DISEASE") > 0 or
						index(upcase(conditions), "CHOLESTEROL") > 0 or index(upcase(conditions), "MITRAL VALVE") > 0 or
						index(upcase(conditions), "SYSTOLIC DYSFUNCTION") > 0
                        );

	%let inf_cond = %str(index(upcase(conditions), "ASPERGILLOSIS") > 0 or index(upcase(conditions), "OTITIS") > 0 or
						 index(upcase(conditions), "COUGH") > 0 or index(upcase(conditions), "PNEUMO") > 0 or
						 index(upcase(conditions), "VIRUS") > 0 or index(upcase(conditions), "RESPIRATORY SYNCYTIAL VIRUSES") > 0 or
						 index(upcase(conditions), "BACTERIA") > 0 or index(upcase(conditions), "FUNG") > 0 or
						 index(upcase(conditions), "VARICELLA") > 0 or index(upcase(conditions), "CMV") > 0 or
						 index(upcase(conditions), "INFECT") > 0 or index(upcase(conditions), "CLOSTRIDIUM") > 0 or
						 index(upcase(conditions), "HPV") > 0 or index(upcase(conditions), "HEPATITIS") > 0 or 
						 index(upcase(conditions), "SEPSIS") > 0 or index(upcase(conditions), "ENDOMETRITIS") > 0 or
						 index(upcase(conditions), "HIV") > 0 );

	%let diab_endo_cond = %str(index(upcase(conditions), "DIABETES") > 0 or index(upcase(conditions), "THYROID") > 0 or
						 index(upcase(conditions), "OSTEOPOROSIS") > 0 or index(upcase(conditions), "ADDISON") > 0 or
						 index(upcase(conditions), "CUSHING") > 0 or index(upcase(conditions), "GRAVE") > 0 or
						 index(upcase(conditions), "HASHIMOTO") > 0 or index(upcase(conditions), "HYPOGONAD") > 0 
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
	if &inf_cond then COND_INF="INFECTIOUS DISEASES"; 
	if &diab_endo_cond then COND_DE="DIABETES & ENDOCRINOLOGY DISORDERS";

	if (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) then COND_LL="LEUKEMIA & LYMPHOMA" ;

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' and COND_INF = ' ' 
		and COND_DE = ' ' then do;
			put "NCTID: " NCT_NUMBER " & Phase: " phases " Condition: " conditions " for Intervention: " interventions " not mapped.";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;


data msd_ct_da;
	set msd_ct_da0;

	/*MSD Interventions*/
	if index(upcase(Interventions), "9-VALENT HUMAN PAPILLOMAVIRUS VACCINE") or index(upcase(compress(Interventions)), "GARDASIL") > 0 or
	   index(upcase(Interventions), "9VHPV") or index(upcase(compress(Interventions)), "HPV9V") > 0 or
	   index(upcase(Interventions), "V501") or index(upcase(compress(Interventions)), "V-501") > 0 or
	   index(upcase(Interventions), "V503") or index(upcase(compress(Interventions)), "V-503") > 0 or
	   index(upcase(compress(Interventions)), "9VHPVVLP") > 0
		then msd_gardasil="GARDASIL";

	if index(upcase(Interventions), "ISL") or index(upcase(compress(Interventions)), "MK-8591") > 0 or
	   index(upcase(Interventions), "ISLATRAVIR") or index(upcase(compress(Interventions)), "MK8591") > 0
		then msd_8591="ISLATRAVIR";

	if index(upcase(Interventions), "DOR") or index(upcase(compress(Interventions)), "MK-1439") > 0 or
	   index(upcase(Interventions), "DORAVIRINE") or index(upcase(compress(Interventions)), "MK1439") > 0
		then msd_1439="DORAVIRINE";

	if index(upcase(Interventions), "PEMBROLIZUMAB") or index(upcase(compress(Interventions)), "MK-3475") > 0 or
	   index(upcase(Interventions), "KEYTRUDA")  or index(upcase(compress(Interventions)), "MK3475") > 0 
		then msd_3475="PEMBROLIZUMAB";

	if index(upcase(Interventions), "OLAPARIB") or index(upcase(compress(Interventions)), "MK-7339") > 0 or
	   index(upcase(compress(Interventions)), "MK7339") > 0 or index(upcase(compress(Interventions)), "AZD2281") > 0 or
 	   index(upcase(compress(Interventions)), "LYNPARZA") > 0
		then msd_7339="OLAPARIB";

	if index(upcase(Interventions), "LENVATINIB") or index(upcase(compress(Interventions)), "MK-7902") > 0 or
	   index(upcase(compress(Interventions)), "MK7902") > 0 or index(upcase(compress(Interventions)), "E7080") > 0 or
 	   index(upcase(compress(Interventions)), "LENVIMA") > 0  
		then msd_7902="LENVATINIB";

	if index(upcase(compress(Interventions)), "MK-1454") > 0 or index(upcase(compress(Interventions)), "MK1454") > 0 
		then msd_1454="MK-1454";

	if index(upcase(Interventions), "POSACONAZOLE") or index(upcase(compress(Interventions)), "MK-5592") > 0 or
	   index(upcase(Interventions), "•	NOXAFIL")  or index(upcase(compress(Interventions)), "MK5592") > 0 or
	   index(upcase(compress(Interventions)), "SCH056592") > 0
		then msd_5592="POSACONAZOLE";

	if index(upcase(compress(Interventions)), "MK-6482") > 0 or index(upcase(compress(Interventions)), "MK6482") > 0 
		then msd_6482="MK-6482";

	if index(upcase(compress(Interventions)), "V-114") > 0 or index(upcase(compress(Interventions)), "V114") > 0 
		then msd_V114="V114";

	if index(upcase(Interventions), "GEFAPIXANT") or index(upcase(compress(Interventions)), "MK-7264") > 0 or
	   index(upcase(compress(Interventions)), "MK7264") > 0   
		then msd_7264="GEFAPIXANT";

	if index(upcase(compress(Interventions)), "PPCV") > 0 
		then msd_ppcv="PPCV";

	if index(upcase(compress(Interventions)), "MK-5890") > 0 or index(upcase(compress(Interventions)), "MK5890") > 0 
		then msd_5890="MK-5890";

	if index(upcase(compress(Interventions)), "MK-4830") > 0 or index(upcase(compress(Interventions)), "MK4830") > 0 
		then msd_4830="MK-4830";

	if index(upcase(compress(Interventions)), "MK-7684") > 0 or index(upcase(compress(Interventions)), "MK7684") > 0 
		then msd_7684="MK-7684";

	if index(upcase(Interventions), "LETERMOVIR") or index(upcase(compress(Interventions)), "MK-8228") > 0 or
	   index(upcase(compress(Interventions)), "PREVYMIS") > 0 or index(upcase(compress(Interventions)), "MK8228") > 0   
		then msd_8228="LETERMOVIR";

	if index(upcase(compress(Interventions)), "MK-1654") > 0 or index(upcase(compress(Interventions)), "MK1654") > 0 
		then msd_1654="MK-1654";

	if index(upcase(Interventions), "FOSAPREPITANT") or index(upcase(compress(Interventions)), "MK-0517") > 0 or
	   index(upcase(compress(Interventions)), "EMEND") > 0 or index(upcase(compress(Interventions)), "MK0517") > 0   
		then msd_0517="FOSAPREPITANT";

	if index(upcase(Interventions), "ERTUGLIFLOZIN") or index(upcase(compress(Interventions)), "MK-8835") > 0 or
	   index(upcase(compress(Interventions)), "MK8835") > 0   
		then msd_8835="ERTUGLIFLOZIN";

	if index(upcase(Interventions), "REL") or index(upcase(compress(Interventions)), "MK-7655") > 0 or
	   index(upcase(Interventions), "RELEBACTUM") or index(upcase(compress(Interventions)), "MK7655") > 0  
		then msd_7655="RELEBACTUM";

	if index(upcase(Interventions), "SUGAMMADEX") or index(upcase(compress(Interventions)), "MK-8616") > 0 or
	   index(upcase(compress(Interventions)), "MK8616") > 0   
		then msd_8616="SUGAMMADEX";

	if index(upcase(Interventions), "V210") or index(upcase(compress(Interventions)), "V-210") > 0 or
	   index(upcase(compress(Interventions)), "VARIVAX") > 0 
		then msd_V210="VARIVAX";

	if index(upcase(Interventions), "CEFTOLOZANE/TAZOBACTAM") or index(upcase(compress(Interventions)), "MK-7625") > 0 or
	   index(upcase(compress(Interventions)), "MK7625") > 0 or index(upcase(Interventions), "CEFTOLOZANE")  
		then msd_7625="CEFTOLOZANE/TAZOBACTAM";

	if index(upcase(Interventions), "EZETIMIBE") or index(upcase(compress(Interventions)), "MK-0653") > 0 or
	   index(upcase(compress(Interventions)), "MK0653") > 0   
		then msd_0653="EZETIMIBE";

	if index(upcase(Interventions), "DAPTOMYCIN") or index(upcase(compress(Interventions)), "MK-3009") > 0 or
	   index(upcase(compress(Interventions)), "MK3009") > 0   
		then msd_3009="DAPTOMYCIN";

	if index(upcase(Interventions), "VICRIVIROC") or index(upcase(compress(Interventions)), "MK-7690") > 0 or
	   index(upcase(compress(Interventions)), "MK7690") > 0   
		then msd_7690="VICRIVIROC";

	if index(upcase(compress(Interventions)), "MK-4280") > 0 or index(upcase(compress(Interventions)), "MK4280") > 0 
		then msd_4280="MK-4280";

	if index(upcase(compress(Interventions)), "MK-1308") > 0 or index(upcase(compress(Interventions)), "MK1308") > 0 
		then msd_1308="MK-1308";

	if index(upcase(compress(Interventions)), "V-160") > 0 or index(upcase(compress(Interventions)), "V160") > 0 
		then msd_V160="V160";

	if index(upcase(Interventions), "NAVARIXIN") or index(upcase(compress(Interventions)), "MK-7123") > 0 or
	   index(upcase(compress(Interventions)), "MK7123") > 0   
		then msd_7123="NAVARIXIN";

	if index(upcase(Interventions), "EBR/GZR") or index(upcase(compress(Interventions)), "MK-5172") > 0 or
	   index(upcase(compress(Interventions)), "MK5172") > 0 or index(upcase(compress(Interventions)), "ELBASVIR") > 0 
		then msd_5172="EBR/GZR";

	if index(upcase(Interventions), "GOLIMUMAB") or index(upcase(compress(Interventions)), "MK-8259") > 0 or
	   index(upcase(compress(Interventions)), "MK8259") > 0   
		then msd_8259="GOLIMUMAB";

	if index(upcase(Interventions), "BEZLOTOXUMAB") or index(upcase(compress(Interventions)), "MK-6072") > 0 or
	   index(upcase(compress(Interventions)), "MK6072") > 0   
		then msd_6072="BEZLOTOXUMAB";

	if index(upcase(Interventions), "TEDIZOLID") or index(upcase(compress(Interventions)), "MK-1986") > 0 or
	   index(upcase(compress(Interventions)), "MK1986") > 0  or index(upcase(compress(Interventions)), "TR-701") > 0
		then msd_6072="TEDIZOLID";

	if index(upcase(Interventions), "CORIFOLLITROPIN") or index(upcase(compress(Interventions)), "MK-8962") > 0 or
	   index(upcase(compress(Interventions)), "MK8962") > 0   
		then msd_8962="CORIFOLLITROPIN";

	if index(upcase(compress(Interventions)), "MK-0646") > 0 or index(upcase(compress(Interventions)), "MK0646") > 0 
		then msd_0646="MK-0646";


run;


proc contents data=msd_ct_da out=msd_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: msd_cc_int separated by " = ' ' and "
	from msd_ct_cont
	where substr(name,1,3) = "MSD" 
	;
quit;

%put &msd_cc_int. ;

data msd_cc_int_chk;
	set msd_ct_da;
	if &msd_cc_int. = ' ' then do;
		put "NCTID: " NCT_NUMBER " & Intervention: " interventions " & Condition: " conditions " & Phase: " phases " not mapped." ;
		put "             ";
	end;
run;



proc sql noprint ;
	select distinct name into: MSD_int_vars separated by '~'
	from MSD_ct_cont
	where substr(name,1,3) = "MSD" 
	;
    %let intcnt = &sqlobs;
quit;

%put &MSD_int_vars &intcnt;



proc sql noprint ;
	select distinct name into: MSD_cond_vars separated by '~'
	from MSD_ct_cont
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &MSD_cond_vars &condcnt;






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


%cond_int_ph_wt(anlz_ds=MSD_ct_da, cond_mvar=&MSD_cond_vars., num_cond=&condcnt., int_mvar=&MSD_int_vars., num_int=&intcnt.);


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

%sankey_nodes(inds=all_cond_int_ph, outds=outds.msd_sankey, nodes=%str(spnsr|cond|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/msd.html, width=1900, height=900, flow_num=);



proc datasets lib=work kill memtype=data ;
run;






