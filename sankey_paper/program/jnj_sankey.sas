
libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";




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

%get_ds(fl=janssen, outds=JNJ_ct);




/**********STEP 1 - Data Analysis*************/
data JNJ_ct_;
	set JNJ_ct(in=a);

	  if substr(strip(upcase(sponsor_collaborators)), 1, 7) = "JANSSEN" ;

	  SPNSR="JANSSEN";

	  if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);
run;



proc freq data=JNJ_ct_ noprint ;
	table Status / list missing out= JNJ_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=JNJ_cond;
	table Interventions / list missing out=JNJ_int;
	table Outcome_Measures / list missing out=JNJ_out_meas;
	table Phases / list missing out=JNJ_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=JNJ_wt;

run;



data JNJ_ct_da0;
	set JNJ_ct_;

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
						 index(upcase(conditions), "RENAL CARCINOMA") > 0 or index(upcase(conditions), "ADENOCARCINOMA") > 0 or
						 index(upcase(conditions), "GIANT CELL TUMOR OF BONE") > 0
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
						 index(upcase(conditions), "BILIARY CHOLANGITIS") > 0 or index(upcase(conditions), "GRAFT VS HOST DISEASE") > 0 or
						 index(upcase(conditions), "HIDRADENITIS SUPPURATIVA") > 0  
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
						index(upcase(conditions), "SYSTOLIC DYSFUNCTION") > 0 or index(upcase(conditions), "DYSLIPIDEMIA") > 0  
                        );

	%let inf_cond = %str(index(upcase(conditions), "ASPERGILLOSIS") > 0 or index(upcase(conditions), "OTITIS") > 0 or
						 index(upcase(conditions), "COUGH") > 0 or index(upcase(conditions), "PNEUMO") > 0 or
						 index(upcase(conditions), "VIRUS") > 0 or index(upcase(conditions), "RESPIRATORY SYNCYTIAL VIRUSES") > 0 or
						 index(upcase(conditions), "BACTERIA") > 0 or index(upcase(conditions), "FUNG") > 0 or
						 index(upcase(conditions), "VARICELLA") > 0 or index(upcase(conditions), "CMV") > 0 or
						 index(upcase(conditions), "INFECT") > 0 or index(upcase(conditions), "CLOSTRIDIUM") > 0 or
						 index(upcase(conditions), "HPV") > 0 or index(upcase(conditions), "HEPATITIS") > 0 or 
						 index(upcase(conditions), "SEPSIS") > 0 or index(upcase(conditions), "ENDOMETRITIS") > 0 or
						 index(upcase(conditions), "HIV") > 0 or index(upcase(conditions), "MYCOSES") > 0 or
						 index(upcase(conditions), "EBOLA") > 0 or index(upcase(conditions), "INFLU") > 0 or
						 index(upcase(conditions), "LEPROSY") > 0 or index(upcase(conditions), "FEVER") > 0 or
						 index(upcase(conditions), "TUBERCULOSIS") > 0   
						 );

	%let diab_endo_cond = %str(index(upcase(conditions), "DIABETES") > 0 or index(upcase(conditions), "THYROID") > 0 or
						 index(upcase(conditions), "OSTEOPOROSIS") > 0 or index(upcase(conditions), "ADDISON") > 0 or
						 index(upcase(conditions), "CUSHING") > 0 or index(upcase(conditions), "GRAVE") > 0 or
						 index(upcase(conditions), "HASHIMOTO") > 0 or index(upcase(conditions), "HYPOGONAD") > 0 
						 );

	%let neuro_cond = %str(index(upcase(conditions), "DEPRESSI") > 0 or index(upcase(conditions), "SCHIZOPHRENIA") > 0 or
						   index(upcase(conditions), "EPILEPSY") > 0 or index(upcase(conditions), "MIGRAINE") > 0 or
						   index(upcase(conditions), "AUTISM") > 0
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
	if &neuro_cond then COND_NEURO = "NEUROLOGICAL DISORDERS";

	if (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) then COND_LL="LEUKEMIA & LYMPHOMA" ;

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' and COND_INF = ' ' 
		and COND_DE = ' ' and COND_NEURO = ' ' then do;
			put "NCTID: " NCT_NUMBER " & Phase: " phases " Condition: " conditions " for Intervention: " interventions " not mapped.";
			put "             ";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;




data JNJ_ct_da;
	set JNJ_ct_da0;

	if index(upcase(Interventions), "GUSELKUMAB") > 0 or index(upcase(compress(Interventions)), "CNTO1959") > 0 or
	   index(upcase(compress(Interventions)), "CNTO-1959") > 0
		then JNJ_CNTO1959="GUSELKUMAB";

	if index(upcase(Interventions), "USTEKINUMAB") > 0 or index(upcase(compress(Interventions)), "STELARA") > 0 
		then JNJ_STELARA="USTEKINUMAB";

	if index(upcase(Interventions), "JNJ-53718678") > 0 or index(upcase(compress(Interventions)), "JNJ53718678") > 0 
		then JNJ_53718678="JNJ-53718678";

	if index(upcase(Interventions), "JNJ-73763989") > 0 or index(upcase(compress(Interventions)), "JNJ73763989") > 0 
		then JNJ_73763989="JNJ-73763989";

	if index(upcase(Interventions), "JNJ-56136379") > 0 or index(upcase(compress(Interventions)), "JNJ56136379") > 0 
		then JNJ_56136379="JNJ-56136379";

	if index(upcase(Interventions), "RILPIVIRINE") > 0 or index(upcase(compress(Interventions)), "TMC278") > 0 or
	   index(upcase(compress(Interventions)), "R278474") > 0 or index(upcase(compress(Interventions)), "EDURANT") > 0
		then JNJ_RILPIVIRINE ="RILPIVIRINE";

	if index(upcase(Interventions), "DARUNAVIR/COBICISTAT/EMTRICITABINE/TENOFOVIR") > 0 or index(upcase(compress(Interventions)), "SYMTUZA") > 0 or
	   index(upcase(compress(Interventions)), "D/C/F/TAF") > 0
		then JNJ_SYMTUZA ="SYMTUZA";

	if index(upcase(Interventions), "IBRUTINIB") > 0 or index(upcase(compress(Interventions)), "IMBRUVICA") > 0 or
	   index(upcase(compress(Interventions)), "PCI-32765") > 0
		then JNJ_IBRUTINIB ="IBRUTINIB";

	if index(upcase(Interventions), "DARATUMUMAB") > 0 or index(upcase(compress(Interventions)), "DARZALEX") > 0  or
	   index(upcase(Interventions), "DARA-SC") > 0 or index(upcase(Interventions), "JNJ-54767414") > 0 or 
	   index(upcase(compress(Interventions)), "JNJ54767414") > 0 or index(upcase(Interventions), "DARA SC") > 0
		then JNJ_DARATUMUMAB="DARATUMUMAB";

	if index(upcase(Interventions), "JNJ-68284528") > 0 or index(upcase(compress(Interventions)), "JNJ68284528") > 0 
		then JNJ_68284528="JNJ-68284528";

	if index(upcase(Interventions), "JNJ-67896049") > 0 or index(upcase(compress(Interventions)), "JNJ67896049") > 0 or
	   index(upcase(Interventions), "SELEXIPAG") > 0 or index(upcase(compress(Interventions)), "UPTRAVI") > 0
		then JNJ_67896049="SELEXIPAG";

	if index(upcase(Interventions), "JNJ-42756493") > 0 or index(upcase(compress(Interventions)), "JNJ42756493") > 0 or
	   index(upcase(Interventions), "ERDAFITINIB") > 0 or index(upcase(compress(Interventions)), "BALVERSA") > 0
		then JNJ_42756493="ERDAFITINIB";

	if index(compress(upcase(Interventions)), "DARUNAVIR|") > 0 or index(upcase(compress(Interventions)), "PREZISTA") > 0 
		then JNJ_DARUNAVIR ="DARUNAVIR";

	if index(upcase(Interventions), "JNJ-56021927") > 0 or index(upcase(compress(Interventions)), "JNJ56021927") > 0 or
	   index(upcase(Interventions), "APALUTAMIDE") > 0 or index(upcase(compress(Interventions)), "ERLEADA") > 0
		then JNJ_56021927="APALUTAMIDE";

	if index(upcase(Interventions), "JNJ-67864238") > 0 or index(upcase(compress(Interventions)), "JNJ67864238") > 0 
		then JNJ_67864238="JNJ-67864238";

	if index(upcase(Interventions), "JNJ-61393215") > 0 or index(upcase(compress(Interventions)), "JNJ61393215") > 0 
		then JNJ_61393215="JNJ-61393215";

	if index(upcase(Interventions), "YH-25448") > 0 or index(upcase(compress(Interventions)), "YH25448") > 0 
		then JNJ_YH25448="YH25448";

	if index(upcase(Interventions), "PALIPERIDONE PALMITATE") > 0 or index(upcase(compress(Interventions)), "PP6M") > 0 or
	   index(upcase(compress(Interventions)), "R092670") > 0
		then JNJ_PP6M ="PP6M";

	if index(upcase(Interventions), "JNJ-74494550") > 0 or index(upcase(compress(Interventions)), "JNJ74494550") > 0 or
	   index(upcase(Interventions), "CUSATUZUMAB") > 0  
		then JNJ_74494550="CUSATUZUMAB";

	if index(upcase(Interventions), "ESKETAMINE") > 0 or index(upcase(compress(Interventions)), "SPRAVATO") > 0 
		then JNJ_ESKETAMINE="ESKETAMINE";

	if index(upcase(Interventions), "JNJ-16269994") > 0 or index(upcase(compress(Interventions)), "JNJ16269994") > 0 or
	   index(upcase(Interventions), "ITRACONAZOLE") > 0  
		then JNJ_16269994="ITRACONAZOLE";

	if index(upcase(Interventions), "JNJ-70033093") > 0 or index(upcase(compress(Interventions)), "JNJ70033093") > 0 
		then JNJ_70033093="JNJ-70033093";

	if index(upcase(Interventions), "JNJ-63871860") > 0 or index(upcase(compress(Interventions)), "JNJ63871860") > 0 or
	   index(upcase(Interventions), "EXPEC") > 0 or index(upcase(compress(Interventions)), "VAC52416") > 0 
		then JNJ_63871860="VAC52416";

	if index(upcase(Interventions), " AD26.ZEBOV") > 0  
		then JNJ_AD26_ZEBOV="AD26.ZEBOV";

	if index(upcase(Interventions), "JNJ-64091742") > 0 or index(upcase(compress(Interventions)), "JNJ64091742") > 0 or
	   index(upcase(Interventions), "NIRAPARIB") > 0 or index(upcase(compress(Interventions)), "ZEJULA") > 0 
		then JNJ_64091742="NIRAPARIB";

	if index(upcase(Interventions), "JNJ-42165279") > 0 or index(upcase(compress(Interventions)), "JNJ42165279") > 0 
		then JNJ_42165279="JNJ-42165279";

	if index(upcase(Interventions), "JNJ-212082") > 0 or index(upcase(compress(Interventions)), "JNJ212082") > 0 or
	   index(upcase(Interventions), "ABIRATERONE") > 0 or index(upcase(compress(Interventions)), "ZYTIGA") > 0 
		then JNJ_212082="ABIRATERONE";

	if index(upcase(Interventions), "GOLIMUMAB") > 0 or index(upcase(compress(Interventions)), "CNTO148") > 0 or
	   index(upcase(compress(Interventions)), "SIMPONI") > 0 
		then JNJ_GOLIMUMAB="GOLIMUMAB";

	if index(upcase(Interventions), "ETRAVIRINE") > 0 or index(upcase(compress(Interventions)), "INTELENCE") > 0 
		then JNJ_ETRAVIRINE="ETRAVIRINE";

	if index(upcase(Interventions), "JNJ-67953964") > 0 or index(upcase(compress(Interventions)), "JNJ67953964") > 0 
		then JNJ_67953964="JNJ-67953964";

	if index(upcase(Interventions), "AD26.RSV") > 0 or index(upcase(compress(Interventions)), "RSV") > 0 
		then JNJ_RSV="AD26.RSV";

	if index(upcase(Interventions), "AD26.MOS4.HIV") > 0  
		then JNJ_AD26_MOS4_HIV="AD26.MOS4.HIV";

	if index(upcase(Interventions), "AD26.MOS.HIV") > 0  
		then JNJ_AD26_MOS_HIV="AD26.MOS.HIV";

	if index(upcase(Interventions), "JNJ-63723283") > 0 or index(upcase(compress(Interventions)), "JNJ63723283") > 0 or
	   index(upcase(Interventions), "CETRELIMAB") > 0  
		then JNJ_63723283="CETRELIMAB";

	if index(upcase(Interventions), "BEDAQUILINE") > 0 or index(upcase(compress(Interventions)), "TMC207") > 0 
		then JNJ_BEDAQUILINE="JNJ-BEDAQUILINE";

	if index(upcase(Interventions), "JNJ-63623872") > 0 or index(upcase(compress(Interventions)), "JNJ63623872") > 0 or
	   index(upcase(Interventions), "PIMODIVIR") > 0  
		then JNJ_63623872="PIMODIVIR";

	if index(upcase(Interventions), "JNJ-64041575") > 0 or index(upcase(compress(Interventions)), "JNJ64041575") > 0 or
	   index(upcase(Interventions), "LUMICITABINE") > 0  
		then JNJ_64041575="LUMICITABINE";

	if index(upcase(Interventions), "JNJ-63682918") > 0 or index(upcase(compress(Interventions)), "JNJ63682918") > 0 or
	   index(upcase(Interventions), "AD26.HPV16") > 0
		then JNJ_63682918="AD26.HPV16";

	if index(upcase(Interventions), "JNJ-63682931") > 0 or index(upcase(compress(Interventions)), "JNJ63682931") > 0 or
	   index(upcase(Interventions), "AD26.HPV18") > 0
		then JNJ_63682931="AD26.HPV18";

	if index(upcase(Interventions), "JNJ-65195208") > 0 or index(upcase(compress(Interventions)), "JNJ65195208") > 0 or
	   index(upcase(Interventions), "MVA.HPV16/18") > 0
		then JNJ_65195208="MVA.HPV16/18";

	if index(upcase(Interventions), "JNJ-64400141") > 0 or index(upcase(compress(Interventions)), "JNJ64400141") > 0 or
	   index(upcase(Interventions), "AD26.RSV.PREF") > 0
		then JNJ_64400141="AD26.RSV.PREF";

	if index(upcase(Interventions), "JNJ-28431754") > 0 or index(upcase(compress(Interventions)), "JNJ28431754") > 0 or
	   index(upcase(Interventions), "CANAGLIFLOZIN") > 0 or index(upcase(compress(Interventions)), "INVOKANA") > 0 
		then JNJ_28431754="CANAGLIFLOZIN";

	if index(upcase(Interventions), "JNJ-56022473") > 0 or index(upcase(compress(Interventions)), "JNJ56022473") > 0 or
	   index(upcase(Interventions), "TALACOTUZUMAB") > 0
		then JNJ_56022473="TALACOTUZUMAB";

	if index(upcase(Interventions), "JNJ-64304500") > 0 or index(upcase(compress(Interventions)), "JNJ64304500") > 0 
		then JNJ_64304500="JNJ-64304500";

	if index(upcase(Interventions), "JNJ-39039039") > 0 or index(upcase(compress(Interventions)), "JNJ39039039") > 0 or
	   index(upcase(Interventions), "RIVAROXABAN") > 0 or index(upcase(compress(Interventions)), "XARELTO") > 0 
		then JNJ_39039039="RIVAROXABAN";

	if index(upcase(Interventions), "PALIPERIDONE") > 0 or index(upcase(compress(Interventions)), "INVEGA") > 0 
		then JNJ_PALIPERIDONE="PALIPERIDONE";

	if index(upcase(Interventions), "TOPIRAMATE") > 0 or index(upcase(compress(Interventions)), "TOPAMAX") > 0 
		then JNJ_TOPIRAMATE="TOPIRAMATE";

	if index(upcase(Interventions), "SILTUXIMAB") > 0 or index(upcase(compress(Interventions)), "SYLVANT") > 0 
		then JNJ_SILTUXIMAB="SILTUXIMAB";

run;


proc contents data=JNJ_ct_da out=JNJ_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: JNJ_cc_int separated by " = ' ' and "
	from JNJ_ct_cont
	where substr(name,1,3) = "JNJ" 
	;
quit;

%put &JNJ_cc_int. ;

data JNJ_cc_int_chk;
	set JNJ_ct_da;
	if &JNJ_cc_int. = ' ' then do;
		put "NCTID: " NCT_NUMBER " & Intervention: " interventions " & Condition: " conditions " & Phase: " phases " not mapped." ;
		put "             ";
	end;
run;




proc sql noprint ;
	select distinct name into: JNJ_int_vars separated by '~'
	from JNJ_ct_cont
	where substr(name,1,3) = "JNJ" 
	;
    %let intcnt = &sqlobs;
quit;

%put &JNJ_int_vars &intcnt;



proc sql noprint ;
	select distinct name into: JNJ_cond_vars separated by '~'
	from JNJ_ct_cont
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &JNJ_cond_vars &condcnt;






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


%cond_int_ph_wt(anlz_ds=JNJ_ct_da, cond_mvar=&JNJ_cond_vars., num_cond=&condcnt., int_mvar=&JNJ_int_vars., num_int=&intcnt.);


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

%sankey_nodes(inds=all_cond_int_ph, outds=outds.JNJ_sankey, nodes=%str(spnsr|cond|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/JNJ.html, width=2400, height=1200, flow_num=);



proc datasets lib=work kill memtype=data nodetails;
run;










