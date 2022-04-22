
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

%get_ds(fl=regen, outds=regen_ct);



/**********STEP 1 - Data Analysis*************/
data regen_ct_;
	set regen_ct(in=a);

	  if substr(strip(lowcase(sponsor_collaborators)), 1, 5) = "regen" ;

	  SPNSR="Regeneron";

	  if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);

	  org_status=status;
	  if status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") then status = "On-going";
run;


proc freq data=regen_ct_ noprint ;
	table Status / list missing out= regen_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=regen_cond;
	table Interventions / list missing out=regen_int;
	table Outcome_Measures / list missing out=regen_out_meas;
	table Phases / list missing out=regen_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=regen_wt;

run;


data regen_ct_da0;
	set regen_ct_;

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
						index(upcase(conditions), "HEMOPHILIA") > 0 or index(upcase(conditions), "HEMOGLOBINURIA") > 0 or
						index(upcase(conditions), "ANEMIA") > 0 or index(upcase(conditions), "MALIGNANCIES") > 0 
						);

	%let mf_cond = %str(index(upcase(conditions), "MYELOFIBROSIS") > 0 or index(upcase(conditions), "MF") > 0 );

	%let onc_cond = %str( index(upcase(conditions), "SOLID TUMOR") > 0 or index(upcase(conditions), "TUMORS") > 0 or
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
						 index(upcase(conditions), "GIANT CELL TUMOR OF BONE") > 0 or index(upcase(conditions), "LEIOMYOSARCOMA") > 0 or
						 index(upcase(conditions), "CARCINOMA")
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
						 index(upcase(conditions), "HIDRADENITIS SUPPURATIVA") > 0 or index(upcase(conditions), "ALLERGIC RHINITIS") > 0 or
						 index(upcase(conditions), "IMMUNOCOMPROMISED") > 0 or index(upcase(conditions), "BULLOUS PEMPHIGOID") > 0
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
						index(upcase(conditions), "SYSTOLIC DYSFUNCTION") > 0 or index(upcase(conditions), "DYSLIPIDEMIA") > 0 or
						index(upcase(conditions), "HYPERTRIGLYCERIDEMIA") > 0
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
						   index(upcase(conditions), "AUTISM") > 0 or index(upcase(conditions), "AMYOTROPHIC LATERAL SCLEROSIS") > 0 or 
						   index(upcase(conditions), "LEIGH SYNDROME") > 0 or
						   index(upcase(conditions), "ALPERS DISEASE") > 0 or index(upcase(conditions), "NEUROMUSCULAR DISEASES") > 0 or
						   index(upcase(conditions), "NERVOUS SYSTEM DISEASES") > 0 or index(upcase(conditions), "PARKINSON") > 0
						 );


	%let gen_cond=%str(index(upcase(conditions), "AADC DEFICIENCY") > 0 or index(upcase(conditions), "AMINO ACID METABOLISM") > 0 or
						index(upcase(conditions), "INBORN ERRORS") > 0 or index(upcase(conditions), "ANIRIDIA") > 0  or 
						index(upcase(conditions), "BH4 DEFICIENCY") > 0 or 	index(upcase(conditions), "CYSTIC FIBROSIS") or
						index(upcase(conditions), "MUSCULAR DYSTROPHY") > 0 or index(upcase(conditions), "DYSTROPHINOPATHY") > 0 or
						index(upcase(conditions), "HEMOPHILIA") > 0 or index(upcase(conditions), "MITOCHONDRIAL DISEASES") > 0 or
						index(upcase(conditions), "MITOCHONDRIAL ENCEPHALOPATHY") > 0 or index(upcase(conditions), "PONTOCEREBELLAR HYPOPLASIA TYPE 6") > 0 or
						index(upcase(conditions), "NEUROFIBROMATOSIS 2") > 0 or index(upcase(conditions), "FRIEDREICH ATAXIA") > 0 or 
						index(upcase(conditions), "FRIEDREICH'S ATAXIA") > 0 or index(upcase(conditions), "CHAPLE") > 0 or 
						index(upcase(conditions), "CD55-DEFICIENT PROTEIN-LOSING ENTEROPATHY") > 0 or index(upcase(conditions), "LIPODYSTROPHY") > 0
						);

	%let resp_cond=%str(index(upcase(conditions), "ASTHMA") > 0  );

	%let met_cond=%str(index(upcase(conditions), "PHENYLKETONURIA") > 0 or index(upcase(conditions), "HYPERPHENYLALANINEMIA") > 0 );


	%let gastro_cond=%str(index(upcase(conditions), "GASTROPARESIS") > 0 );

	%let hepat_cond=%str(index(upcase(conditions), "HEPATIC IMPAIRMENT") > 0 );

	%let covid_cond=%str(index(upcase(conditions),"COVID-19") > 0 or index(upcase(conditions),"CORONAVIRUS") > 0 or
						 index(upcase(conditions),"SARS-COV-2") > 0
						);

	%let renal_cond=%str(index(upcase(conditions), "RENAL IMPAIRMENT") > 0 );

	%let healthy_cond=%str(index(upcase(conditions), "HEALTHY") > 0 );

	%let opth_cond=%str(index(upcase(conditions), "RETINOPATHY") > 0 or index(upcase(conditions), "MACULAR DEGENERATION") > 0
					);


	if &MM_cond then MM="MULTIPLE MYELOMA";
	if &mds_cond then MDS="MDS";
	if &aml_cond then AML="AML";
	if &lym_cond then LYM="LYMPHOMA";
	if &cc_cond then CLL="CLL";
	if &bd_cond then COND_bt="BLOOD DISORDERS";
	if &mf_cond then MF="MF";
	if &onc_cond then COND_ONC="ONCOLOGY";
	if &ii_cond then COND_II="INFLAMMATION & IMMUNOLOGY"; 
	if &cv_cond then COND_CV="CARDIOVASCULAR & KIDNEY DISEASE";
	if &leuk_cond then LEUK="LEUKEMIA";
	if &inf_cond then COND_INF="INFECTIOUS DISEASES"; 
	if &diab_endo_cond then COND_DE="DIABETES & ENDOCRINOLOGY DISORDERS";
	if &neuro_cond then COND_NEURO = "NEUROLOGICAL DISORDERS";

	if &gen_cond then COND_GEN="GENETIC DISORDERS";
	if &met_cond then COND_MET="METABOLIC DISORDERS";
	if &gastro_cond then COND_GASTRO = "GASTRIC DISORDERS";
	if &hepat_cond then COND_HEPAT = "HEPATIC DISORDERS";
	if &covid_cond then COND_COVID = "COVID-19";
	if &renal_cond then COND_HEPAT = "RENAL DISORDERS";
	if &healthy_cond then COND_HEALTH = "HEALTHY SUBJECTS";
	if &resp_cond then COND_RESP = "RESPIRATORY";
	if &opth_cond then COND_OPTH = "OPHTHALMOLOGY";

	if (&mm_cond) or (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) or (&bd_cond) then COND_HEM="HEMATOLOGY" ;

	if MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' and COND_INF = ' ' 
		and COND_DE = ' ' and COND_NEURO = ' ' and COND_GEN = ' ' and COND_MET = ' ' and COND_ONC = ' ' and COND_GASTRO = ' ' 
		and COND_HEPAT = ' ' and COND_COVID = ' ' and COND_RENAL = ' ' and COND_HEALTH = ' ' and COND_RESP = ' ' and COND_OPTH = ' '
		then do;
			put "NCTID: " NCT_NUMBER " & Phase: " phases " Condition: " conditions " for Intervention: " interventions " not mapped.";
			put "             ";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;


data regen_ct_da;
	set regen_ct_da0;

	/*regen Interventions*/
	if index(upcase(Interventions), "REGN5054") > 0 then REG_5054="REGN5054";

	if index(upcase(Interventions), "CEMIPLIMAB") > 0 or index(upcase(Interventions), "LIBTAYO")  or index(upcase(Interventions), "REGN-2810") or
		index(upcase(Interventions), "SAR-439684") > 0 or index(upcase(Interventions), "SAR439684")  or index(upcase(Interventions), "REGN2810") or 
		index(upcase(Interventions), "GTPL10090")
		then REG_CEMI="CEMIPLIMAB";

	if index(upcase(Interventions), "IMDEVIMAB") > 0 or index(upcase(Interventions), "RONAPREVE")  or index(upcase(Interventions), "REGN-10987") or
		index(upcase(Interventions), "REGN10987") or 
		index(upcase(Interventions), "GTPL11328")
		then REG_IMDE="IMDEVIMAB";

	if index(upcase(Interventions), "POZELIMAB") > 0 or index(upcase(Interventions), "REGN-3918")  or index(upcase(Interventions), "REGN3918") 
		then REG_PZE="POZELIMAB";

	if index(upcase(Interventions), "DUPILUMAB") > 0 or index(upcase(Interventions), "REGN 668")  or index(upcase(Interventions), "REGN668") or
		index(upcase(Interventions), "REGN10987") or 
		index(upcase(Interventions), "REGN-668") or index(upcase(Interventions), "SAR231893")  or index(upcase(Interventions), "SAR-231893")
		then REG_DUPI="DUPILUMAB";

	if index(upcase(Interventions), "EVINACUMAB") > 0 or index(upcase(Interventions), "REGN-1500")  or index(upcase(Interventions), "REGN1500") 
		then REG_EVIN="EVINACUMAB";

	if index(upcase(Interventions), "ODRONEXTAMAB") > 0 or index(upcase(Interventions), "REGN-1979")  or index(upcase(Interventions), "REGN1979") 
		then REG_ODRO="ODRONEXTAMAB";

	if index(upcase(Interventions), "MIBAVADEMAB") > 0 or index(upcase(Interventions), "REGN-4461")  or index(upcase(Interventions), "REGN4461") 
		then REG_MIBA="MIBAVADEMAB";

	if index(upcase(Interventions), "REGN14256") > 0 or index(upcase(Interventions), "REGN-14256")   
		then REG_14256="REGN14256";

	if index(upcase(Interventions), "CASIRIVIMAB") > 0 or index(upcase(Interventions), "RONAPREVE")  or index(upcase(Interventions), "REGN-10933") or
		index(upcase(Interventions), "REGN10933") or 
		index(upcase(Interventions), "GTPL11327")
		then REG_CASI="CASIRIVIMAB";

	if index(upcase(Interventions), "REGN1908-1909") > 0 then REG_1908_1909="REGN1908-1909";

	if index(upcase(Interventions), "FIANLIMAB") > 0 or index(upcase(Interventions), "REGN-3767")  or index(upcase(Interventions), "REGN3767") 
		then REG_FIAN="FIANLIMAB";

	if index(upcase(Interventions), "UBAMATAMAB") > 0 or index(upcase(Interventions), "REGN-4018")  or index(upcase(Interventions), "REGN4018") 
		then REG_UBA="UBAMATAMAB";

	if index(upcase(Interventions), "REGN4336") > 0 then REG_4336="REGN4336";

	if index(upcase(Interventions), "REGN5093") > 0 then REG_5093="REGN5093";

	if index(upcase(Interventions), "LINVOSELTAMAB") > 0 or index(upcase(Interventions), "REGN-5458")  or index(upcase(Interventions), "REGN5458") 
		then REG_LIN="LINVOSELTAMAB";

	if index(upcase(Interventions), "REGN5459") > 0 then REG_5459="REGN5459";

	if index(upcase(Interventions), "REGN5668") > 0 then REG_5668="REGN5668";
	
	if index(upcase(Interventions), "REGN7075") > 0 then REG_7075="REGN7075";

	if index(upcase(Interventions), "REGN7257") > 0 then REG_7257="REGN7257";

	if index(upcase(Interventions), "AFLIBERCEPT") > 0 then REG_AFL="AFLIBERCEPT [Eylea]";

	if index(upcase(Interventions), "RGX-314") > 0 then REG_RGX_314="RGX-314";

run;


proc contents data=regen_ct_da out=regen_ct_cont noprint ;
run;

proc sql noprint ;
	select name into: regen_cc_int separated by " = ' ' and "
	from regen_ct_cont
	where substr(name,1,3) = "REG" 
	;
quit;

%put &regen_cc_int. ;

data regen_cc_int_chk;
	set regen_ct_da;
	if &regen_cc_int. = ' ' then do;
		put "Sponsor: " SPNSR " & Condition: " conditions " & Intervention: " interventions " & Phase: " phases " not mapped";
	end;
run;


proc sql;
	create table cond_int as
	select a.name as cond, b.name as int, "cond_int_adv" as macnm
	from regen_ct_cont(where=(substr(name,1,5) = "COND_")) as a, regen_ct_cont(where=(substr(name,1,3) = "REG")) as b
	;
quit;


%macro cond_int_adv(_cond=, _int=);

	proc freq data=regen_ct_da noprint;
		table spnsr*&_cond.*&_int.*phases  / missing out=__&_cond._&_int.(where=(&_int. ne " " and &_cond. ne " " ) 
																					     drop=percent) ;
	run; 

	proc sql noprint ;
		select count(&_cond.) into: cond_chk_cnt
		from __&_cond._&_int.
		;
	quit;

	%if &cond_chk_cnt. > 0 %then %do;
		data __&_cond._&_int.;
			length cond int phases $200.;
			set __&_cond._&_int.;
				cond=&_cond.;
				INT=&_int. ;
				drop &_cond. &_int. ;
		run;
	%end;

	%else %do;
		proc datasets lib=work nolist;
			delete __&_cond._&_int.;
		quit;
		run;
	%end;
%mend cond_int_adv;


data _null_;
	set cond_int;
		
	mac_str = cats('%nrstr(%', macnm, '(_cond=', cond, ', _int=', int, '))');

	call execute(mac_str);
run;



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

%sankey_nodes(inds=all_cond_int_ph, outds=outds.regen_sankey, nodes=%str(spnsr|cond|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/regen2022.html, width=1900, height=550, flow_num=);



proc datasets lib=work kill memtype=data ;
run;
		



