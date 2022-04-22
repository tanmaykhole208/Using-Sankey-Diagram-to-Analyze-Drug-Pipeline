

libname mydoc "/u02/home/tkhole/ct_data" ;
filename fmydoc "/u02/home/tkhole/ct_data" ;

options validvarname=V7;


proc format;
	value $condlbl
	"MM"         =	"MULTIPLE MYELOMA (MM)"
	"MDS"        =	"MYELODYSPLASTIC SYNDROMES (MDS)"
	"AML"        =	"ACUTE MYELOID LEUKEMIA (AML)"
	"LYMPHOMA"   =	"LYMPHOMA"
	"CLL"        =	"CHRONIC LYMPHOCYTIC LEUKEMIA (CLL)"
	"B_T"        =	"BETA-THALASSEMIA"
	"MF"         =	"MYELOFIBROSIS (MF)"
	"ST"         =	"SOLID TUMORS"  
	"II"  	     =	"INFLAMMATION & IMMUNOLOGY"
	"CV"         =  "CARDIOVASCULAR"
	"LL"         =  "LYMPHOMA & LEUKEMIA"
  ;
run; 

options validvarname=v7;

proc import datafile="%sysfunc(pathname(fmydoc,f))/bms-ct.csv"
     out=bms_ct
     dbms=csv
     replace;
     getnames=yes;
	 guessingrows=32767;
run;

options validvarname=upcase;


/**********STEP 1 - Data Analysis*************/
data bms_ct_;
	set bms_ct;
	where phases not in ( ' ' 'Not Applicable') and Interventions ne ' ' and status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") 
;
run;


proc freq data=bms_ct_;
	table Status / list missing out= bms_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=bms_cond;
	table Interventions / list missing out=bms_int;
	table Outcome_Measures / list missing out=bms_out_meas;
	table Phases / list missing out=bms_phases;

	table Status*Interventions*Conditions*Phases / list missing out=bms_wt;

run;


data bms_ct_da;
	set bms_wt;

	/*Interventions*/
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
						 index(upcase(conditions), "STOMA") > 0 or index(upcase(conditions), "NEOPLASM") > 0 or index(upcase(conditions), "HEPAT") > 0 or
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
						 index(upcase(conditions), "SCCHN") > 0 or index(upcase(conditions), "LEUKOPLAKIA") > 0 
						 );




	%let ii_cond = %str( index(upcase(conditions), "PSORIA") > 0 or index(upcase(conditions), "BEHCET") > 0 or
						 index(upcase(conditions), "SCLERO") > 0 or index(upcase(conditions), "COLITIS") > 0 or index(upcase(conditions), "ULCER") > 0 or
						 index(upcase(conditions), "CROHN") > 0 or index(upcase(conditions), "LUPUS") > 0 or
						 index(upcase(conditions), "FIBRO") > 0 or index(upcase(conditions), "ARTHRITIS") > 0 or
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
						 index(upcase(conditions), "GVHD") > 0
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

	if COND_MM = ' ' and mds = ' ' and COND_aml = ' ' and COND_lym = ' ' and COND_lym = ' ' and COND_cll = ' '
		and COND_bt = ' ' and COND_mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and COND_leuk = ' ' then do;
			put "Condition: " conditions " not mapped.";
			chk_cond = "Y";
	end;

run;




proc sql noprint ;
	select nobs into: max_obs
	from sashelp.vtable
	where memname="BMS_CT_DA" and memtype="DATA"
	;
quit;

proc contents data=bms_ct_da out=chk_int noprint ;
run;

proc sql noprint ;
	select distinct name into: bms_int_vars separated by '~'
	from chk_int
	where substr(name,1,4) = "BMS_"
	;
    %let cnt = &sqlobs;
quit;

%put &bms_int_vars &cnt;



proc sql noprint ;
	select distinct name into: bms_int_vars2 separated by " = ' ' and "
	from chk_int
	where substr(name,1,4) = "BMS_"
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


/*

%macro chk_int_vars;

    %do i = 1 %to &cnt;
       %let single = %scan(&bms_int_vars, &i , '~');
       %put single = &single;
			proc freq data=bms_ct_da noprint ;
				   table &single. / missing out=__&single.(where=(&single. = " " and count=&max_obs.)) ;
			run;

		data __&single.;
			length bms_int $200.;
			set __&single.;
				bms_int = "&single.";
				drop &single.;
		run;
    %end;

data all_ckh_int_vars;
	set __bms_: ;
	if bms_int ne ' ' then do;
		put "WAR" "NING: Intervention " bms_int " is not derived.";
	end;
run;	


data all_ckh_int_vars2;
	set bms_ct_da ;
	if &bms_int_vars2. = ' ' then do;
		put "WAR" "NING: Intervention " interventions " and PHASE = " phases " is not mapped to individual drug.";
		chk_int="Y";
	end;
run;	
		

%mend chk_int_vars;

%chk_int_vars;
*/

%macro cond_int_ph_wt;


	%do j =1 %to &condcnt. ;
		%let cond = %scan(&bms_cond_vars, &j , '~');
		%put Condition = &cond. ;
		    %do i = 1 %to &cnt. ;
		       %let single = %scan(&bms_int_vars, &i , '~');
		       %put single = &single;
					proc freq data=bms_ct_da noprint ;
						   table &cond.*&single.*phases  / missing out=__&cond._&single.(where=(&single. ne " " and &cond. ne " " ) 
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
	run;

	proc sql;
		create table all_cond_wt as
			select cond, sum(count) as cond_ct, "            [ 'BMS PIPELINE', '"||strip(put(cond, $condlbl.))||"', "||strip(put(sum(count), 5.0))||"]," as final length=1000
			from all_cond_int_ph
			group by cond
			;
		create table all_cond_int_wt as
			select cond, int, sum(count) as cond_int_ct, "               [ '"||strip(put(cond, $condlbl.))||"', '"||strip(int)||"', "||strip(put(sum(count), 5.0))||"]," as final length=1000
			from all_cond_int_ph
			group by cond, int
			;
		create table all_int_ph_wt as
			select int, phases, sum(count) as int_ph_ct, "                  [ '"||strip(int)||"', '"||strip(phases)||"', "||strip(put(sum(count), 5.0))||"]," as final length=1000
			from all_cond_int_ph
			group by int, phases
			;
	quit;


	data final_wt;
		set all_cond_wt all_cond_int_wt all_int_ph_wt;
		keep final;
	run;


/*
proc datasets lib=work kill ;
run;
*/



