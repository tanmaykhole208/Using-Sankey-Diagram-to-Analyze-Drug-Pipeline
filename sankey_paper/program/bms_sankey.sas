

libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";

options validvarname=V7;


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

%get_ds(fl=bms_ct_20191122, outds=bms_ct);
%get_ds(fl=celg_ct_20191122, outds=cc_ct)



/**********STEP 1 - Data Analysis*************/
data bms_ct_;
	set bms_ct(in=a) cc_ct(in=b drop=rank START_DATE PRIMARY_COMPLETION_DATE COMPLETION_DATE RESULTS_FIRST_POSTED);
	if phases not in ( ' ' 'Not Applicable') and Interventions ne ' ' and status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") ;

	  if a then SPNSRn=1;
	  if b then SPNSRn=2;

	  if substr(strip(upcase(sponsor_collaborators)), 1, 3) = "BMS" or substr(strip(upcase(sponsor_collaborators)), 1, 7) = "BRISTOL" or 
	  	 substr(strip(upcase(sponsor_collaborators)), 1, 7) = "CELGENE";

	  SPNSR="BMS";

	  if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";

	  phases = upcase(phases);

run;



proc freq data=bms_ct_;
	table Status / list missing out= bms_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=bms_cond;
	table Interventions / list missing out=bms_int;
	table Outcome_Measures / list missing out=bms_out_meas;
	table Phases / list missing out=bms_phases;
	table SPNSR / list missing out=spnsr_wt;
	table spnsrn*SPNSR*Status*Interventions*Conditions*Phases / list missing out=bms_wt;

run;


data bms_ct_da0;
	set bms_ct_;

	/*BMS Interventions*/
	if spnsrn=1 then do;
		if index(upcase(Interventions), "BMS-986177") > 0 then BMS_986177="Factor XIa Inhibitor";
		if index(upcase(Interventions), "HNO") > 0 then BMS_nitroxyl="HNO";
		if index(upcase(Interventions), "APIXABAN") > 0 or index(upcase(Interventions), "ELIQUIS") > 0
		or index(upcase(Interventions), "562247") > 0
			then BMS_eliquis="ELIQUIS";
		if index(upcase(Interventions), "BMS-986278") > 0 then BMS_LPA1_Antagonist="LPA1 Antagonist";
		if index(upcase(Interventions), "BMS-986263") > 0 then BMS_HSP47="HSP47";
		if index(upcase(Interventions), "BMS-986036") > 0 or index(upcase(Interventions), "PEGBELFERMIN") > 0
			then BMS_PEGBELFERMIN="PEGBELFERMIN";
		if index(upcase(Interventions), "BMS-986165") > 0 then BMS_986165="TYK2 Inhibitor(1)";
		if index(upcase(Interventions), "ABATACEPT") > 0 or index(upcase(Interventions), "ORENCIA") > 0
		or index(upcase(Interventions), "BMS-188667") > 0
			then BMS_ORENCIA="ORENCIA";
		if index(upcase(Interventions), "BELATACEPT") > 0 or index(upcase(Interventions), "NULOJIX") > 0
		or index(upcase(Interventions), "BMS-224818") > 0
			then BMS_NULOJIX="NULOJIX";
		if index(upcase(Interventions), "BMS-986179") > 0 then BMS_986179="Anti-CD73";
		if index(upcase(Interventions), "BMS-986218") > 0 then BMS_986218="Anti-CTLA-4 NF";
		if index(upcase(Interventions), "BMS-986249") > 0 then BMS_986249="Anti-CTLA-4 Probody";
		if index(upcase(Interventions), "BMS-986226") > 0 then BMS_986226="Anti-ICOS";
		if index(upcase(Interventions), "BMS-986207") > 0 then BMS_986207="Anti-TIGIT";
		if index(upcase(Interventions), "BMS-986310") > 0 then BMS_986310="EP4 Antagonist";
		if index(upcase(Interventions), "BMS-986253") > 0 then BMS_986253="HuMax-IL8";
		if index(upcase(Interventions), "BMS-986299") > 0 then BMS_986299="NLRP3 Agonist";
		if index(upcase(Interventions), "BMS-986301") > 0 then BMS_986299="STING Agonist";
		if index(upcase(Interventions), "BMS-986227") > 0 or index(upcase(Interventions), "CABIRALIZUMAB") > 0
			then BMS_CABIRALIZUMAB="CABIRALIZUMAB";
		if index(upcase(Interventions), "BMS-813160") > 0 then BMS_813160="CCR2/5 Dual Antagonist";
		if index(upcase(Interventions), "BMS-986205") > 0 then BMS_986205="IDO Inhibitor(1)";
		if index(upcase(Interventions), "NKTR-214") > 0 then BMS_NKTR_214="NKTR-214";
		if index(upcase(Interventions), "BMS-986016") > 0 or index(upcase(Interventions), "RELATLIMAB") > 0
			or index(upcase(Interventions), "BMS 986016") > 0 then BMS_RELATLIMAB="RELATLIMAB";
		if index(upcase(Interventions), "DASATINIB") > 0 or index(upcase(Interventions), "SPRYCEL") > 0
		or index(upcase(Interventions), "BMS-354825") > 0
			then BMS_DASATINIB="DASATINIB";
		if index(upcase(Interventions), "ELOTUZUMAB") > 0 or index(upcase(Interventions), "EMPLICITI") > 0
		or index(upcase(Interventions), "BMS-901608") > 0
			then BMS_ELOTUZUMAB="ELOTUZUMAB";
		if index(upcase(Interventions), "IPILIMUMAB") > 0 or index(upcase(Interventions), "YERVOY") > 0
		or index(upcase(Interventions), "BMS-734016") > 0
			then BMS_IPILIMUMAB="IPILIMUMAB";
		if index(upcase(Interventions), "NIVOLUMAB") > 0 or index(upcase(Interventions), "OPDIVO") > 0
		or index(upcase(Interventions), "BMS-936558") > 0 or index(upcase(Interventions), "ONO-4538")
			then BMS_NIVOLUMAB="NIVOLUMAB";
		if index(upcase(Interventions), "BMS-986012") > 0 then BMS_986299="BMS-986012";
		if index(upcase(Interventions), "BMS-986231") > 0 then BMS_986299="BMS-986231";
		if index(upcase(Interventions), "BMS-986224") > 0 then BMS_986299="BMS-986224";
		if index(upcase(Interventions), "BMS-986231") > 0 then BMS_986231="BMS-986231";
		if index(upcase(Interventions), "BMS-986235") > 0 then BMS_986235="BMS-986235";
		if index(upcase(Interventions), "BMS-986256") > 0 then BMS_986256="BMS-986256";
		if index(upcase(Interventions), "BMS-986259") > 0 then BMS_986259="BMS-986259";
		if index(upcase(Interventions), "DACLATASVIR") > 0 or index(upcase(Interventions), "DAKLINZA") > 0
		or index(upcase(Interventions), "BMS-790052") > 0 
			then BMS_DACLATASVIR="DACLATASVIR";
		if index(upcase(Interventions), "ULOCUPLUMAB") > 0 or index(upcase(Interventions), "BMS-936564") > 0 
			then BMS_ULOCUPLUMAB="ULOCUPLUMAB";
	end;


	/*CELGENE Interventions*/
	if spnsrn=2 then do;
		if (index(upcase(Interventions), "LENALIDOMIDE") > 0 or index(upcase(Interventions), "REVLIMID") > 0)
			then CELG_LENALIDOMIDE="LENALIDOMIDE";

		if (index(upcase(Interventions), "POMALIDOMIDE") > 0 or index(upcase(Interventions), "POMALYST") > 0 or
	        index(upcase(Interventions), "IMNOVID") > 0 or index(upcase(Interventions), "POM|") > 0)
			then CELG_POMALIDOMIDE="POMALIDOMIDE";

		if (index(upcase(Interventions), "THALIDOMIDE") > 0 or index(upcase(Interventions), "THALOMID") > 0 )
	        then CELG_THALIDOMIDE="THALIDOMIDE";

		if (index(upcase(Interventions), "BB2121") > 0 )
			then CELG_BB2121="BB2121";
			          
		if (index(upcase(Interventions), "BB21217") > 0 )
			then CELG_BB21217="BB21217";

		if (index(upcase(Interventions), "JCARH125") > 0 )
			then CELG_JCARH125="JCARH125";

		if (index(upcase(Interventions), "IBERDOMIDE") > 0 or index(upcase(Interventions), "CC-220") > 0 )
			then CELG_Iberdomide="IBERDOMIDE";

		if (index(upcase(Interventions), "CC-92480") > 0 or index(upcase(Interventions), "CELMOD") > 0 )
			then CELG_CC_92480="CC-92480";

		if (index(upcase(Interventions), "CC-93269") > 0 or index(upcase(Interventions), "BCMA TCE") > 0 )
			then CELG_CC_93269="CC-93269";

		if (index(upcase(Interventions), "AZACITIDINE") > 0 or index(upcase(Interventions), "VIDAZA") > 0)
			then CELG_AZACITIDINE="AZACITIDINE";

		if (index(upcase(Interventions), "CC-486") > 0 or index(upcase(Interventions), "DNMT") > 0)
			then CELG_CC_486="CC-486";

		if (index(upcase(Interventions), "LUSPATERCEPT") > 0 or index(upcase(Interventions), "ACE-536") > 0)
			then CELG_Luspatercept="LUSPATERCEPT";

		if (index(upcase(Interventions), "ENASIDENIB") > 0 or index(upcase(Interventions), "IDHIFA") > 0)
			then CELG_ENASIDENIB="ENASIDENIB";

		if (index(upcase(Interventions), "CC-90009") > 0 or index(upcase(Interventions), "CELMOD") > 0)
			then CELG_CC_90009="CC-90009";

		if (index(upcase(Interventions), "GEM333") > 0 or index(upcase(Interventions), "CD3XCD33") > 0)
			then CELG_GEM333="GEM333";

		if (index(upcase(Interventions), "CC-95775") > 0 or index(upcase(Interventions), "(BET INHIBITOR") > 0)
			then CELG_CC_95775="CC-95775";

		if (index(upcase(Interventions), "ROMIDEPSIN") > 0 or index(upcase(Interventions), "ISTODAX") > 0)
			then CELG_ROMIDEPSIN="ROMIDEPSIN";

		if (index(upcase(Interventions), "LISO-CEL") > 0 or index(upcase(Interventions), "CD-19") > 0)
			or index(upcase(Interventions), "LISOCABTAGENE") > 0
			then CELG_LISO_CEL="LISO-CEL";

		if (index(upcase(Interventions), "CC-90002") > 0 or index(upcase(Interventions), "CD47") > 0)
			then CELG_CC_90002="CC-90002";

		if (index(upcase(Interventions), "AVADOMIDE") > 0 or index(upcase(Interventions), "CC-122") > 0)
			then CELG_AVADOMIDE="AVADOMIDE";

		if (index(upcase(Interventions), "CC-90010") > 0 )
			then CELG_CC_90010="CC-90010";

		if (index(upcase(Interventions), "CC-115") > 0 )
			then CELG_CC_115="CC-115";

		if (index(upcase(Interventions), "FEDRATINIB") > 0 )
			then CELG_FEDRATINIB="FEDRATINIB";

		if (index(upcase(Interventions), "ABRAXANE") > 0 or index(upcase(Interventions), "PACLITAXEL") > 0 )
			then CELG_ABRAXANE="ABRAXANE";

		if (index(upcase(Interventions), "MARIZOMIB") > 0 )
			then CELG_MARIZOMIB="MARIZOMIB";

		if (index(upcase(Interventions), "TISLELIZUMAB") > 0 or index(upcase(Interventions), "BGB-A317") > 0 )
			then CELG_TISLELIZUMAB="TISLELIZUMAB";

		if (index(upcase(Interventions), "CC-90011") > 0 )
			then CELG_CC_90011="CC-90011";

		if (index(upcase(Interventions), "CC-99282") > 0 )
			then CELG_CC_90011="CC-99282";

		if (index(upcase(Interventions), "CC-95251") > 0 )
			then CELG_CC_95251="CC-95251";

		if (index(upcase(Interventions), "OTEZLA") > 0 or index(upcase(Interventions), "APREMILAST") > 0) or
			index(upcase(Interventions), "CC-10004") > 0
			then CELG_OTEZLA="OTEZLA";

		if (index(upcase(Interventions), "OZANIMOD") > 0 or index(upcase(Interventions), "RPC1063") > 0 )
			then CELG_OZANIMOD="OZANIMOD";

		if (index(upcase(Interventions), "CC-93538") > 0 )
			then CELG_CC_93538="CC-93538";

		if (index(upcase(Interventions), "CC-90001") > 0 )
			then CELG_CC_90001="CC-90001";

		if (index(upcase(Interventions), "CC-90006") > 0 )
			then CELG_CC_90006="CC-90006";
	end;




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
 

	%let bt_cond = %str(index(upcase(conditions), "BETA-THALASSEMIA") > 0 or index(upcase(conditions), "THALASSEMIA") > 0 );

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
						 index(upcase(conditions), "HEPATIC CARCINOMA") > 0
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
						index(upcase(conditions), "VENTRICULAR DYSFUNCTION") > 0 or index(upcase(conditions), "VENTRICULAR FAILURE") > 0 
                        );

	if &MM_cond then COND_MM="MM";
	if &mds_cond then MDS="MDS";
	if &aml_cond then AML="AML";
	if &lym_cond then LYM="LYMPHOMA";
	if &cc_cond then CLL="CLL";
	if &bt_cond then COND_bt="B_T";
	if &mf_cond then MF="MF";
	if &st_cond then COND_ST="ST";
	if &ii_cond then COND_II="II";
	if &cv_cond then COND_CV="CV";
	if &leuk_cond then LEUK="LEUKEMIA";

	if (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) then COND_LL="LL" ;

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' then do;
			put "Sponsor: " SPNSR " & Condition: " conditions " not mapped.";
			chk_cond = "Y";
	end;


run;

proc contents data=bms_ct_da0 out=bms_ct_cont0 noprint ;
run;


/*****Remove observations with crossing sponsor-interventions******/
/*
proc sql noprint ;
	select name into: cc_int separated by " ne ' ' and spnsrn=1 then %superq(&cc_int.)=' '; if "
	from bms_ct_cont0
	where  substr(name,1,5) = "CELG_"
	;
	select name into: bms_int separated by " ne ' ' and spnsrn=2 then delete; if "
	from bms_ct_cont0
	where  substr(name,1,4) = "BMS_"
	;
quit;

%put &cc_int. ;

%put &bms_int. ;
*/

data bms_ct_da;
	set bms_ct_da0;
	/*if &cc_int.  ne ' ' and spnsrn=1 then delete; 
	if &bms_int. ne ' ' and spnsrn=2 then delete;*/

	if spnsrn=2 and CELG_OTEZLA="OTEZLA" then delete;
run;
/*****************************************************/

proc contents data=bms_ct_da out=bms_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: bms_cc_int separated by " = ' ' and "
	from bms_ct_cont
	where substr(name,1,4) = "BMS_" or substr(name,1,5) = "CELG_"
	;
quit;

%put &bms_cc_int. ;

data bms_cc_int_chk;
	set bms_ct_da;
	if &bms_cc_int. = ' ' then do;
		put "Sponsor: " SPNSR " & Condition: " conditions " & Intervention: " interventions " & Phase: " phases " not mapped";
	end;
run;



proc contents data=bms_ct_da out=chk_int noprint ;
run;

proc sql noprint ;
	select distinct name into: bms_int_vars separated by '~'
	from chk_int
	where substr(name,1,4) = "BMS_" or substr(name,1,5) = "CELG_"
	;
    %let cnt = &sqlobs;
quit;

%put &bms_int_vars &cnt;



proc sql noprint ;
	select distinct name into: bms_int_vars2 separated by " = ' ' and "
	from chk_int
	where substr(name,1,4) = "BMS_" or substr(name,1,5) = "CELG_"
	;
quit;

%put &bms_int_vars2;



proc sql noprint ;
	select distinct name into: bms_cond_vars separated by '~'
	from chk_int
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &bms_cond_vars &condcnt;

%macro cond_int_ph_wt;


	%do j =1 %to &condcnt. ;
		%let cond = %scan(&bms_cond_vars, &j , '~');
		%put Condition = &cond. ;
		    %do i = 1 %to &cnt. ;
		       %let single = %scan(&bms_int_vars, &i , '~');
		       %put single = &single;
					proc freq data=bms_ct_da noprint ;
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


%cond_int_ph_wt;


	data all_cond_int_ph;
		length cond int phases $200.;
		set __cond_:;

		cond1 = strip(put(cond, $condlbl.));
			int  = strip(int);
			phases=strip(phases);

			do i=1 to count;
				output;
			end;
	run;


		



%macro sankey_nodes(inds=all_cond_int_ph, outds=, nodes=%str(spnsr|cond1|int|phases), cond=);

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

%sankey_nodes(inds=all_cond_int_ph, outds=outds.bms_sankey, nodes=%str(spnsr|cond1|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/bms.html, width=1900, height=900, flow_num=);


proc datasets lib=work kill memtype=data ;
run;
