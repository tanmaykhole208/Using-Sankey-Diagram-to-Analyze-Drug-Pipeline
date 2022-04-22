
libname mydoc "/u02/home/tkhole/ct_data" ;
filename fmydoc "/u02/home/tkhole/ct_data" ;

options validvarname=V7;

proc import datafile="%sysfunc(pathname(fmydoc,f))/celg-ct.csv"
     out=cc_ct
     dbms=csv
     replace;
     getnames=yes;
run;


/**********STEP 1 - Data Analysis*************/
data cc_ct_;
	set cc_ct;
	where phases ne ' ' and Interventions ne ' ' and status in ("Active, not recruiting" 
      /*"Approved for marketing"*/  
      "Available"  
      /*"Completed"  */
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") ;
run;


proc contents data=cc_ct out=cc_ct_cont;
run;

proc sort data=cc_ct_cont;
	by varnum;
run;

proc freq data=cc_ct_;
	table Status / list missing out= status;
	table Study_Results / list missing ;
	table Conditions / list missing out=cond;
	table Interventions / list missing out=int;
	table Outcome_Measures / list missing out=out_meas;
	table Phases / list missing out=phases;

	table Status*Interventions*Conditions*Phases / list missing out=cc_wt;

run;




/****************************************************/
/***********************STEP 2***********************/
/*** Weightage of Conditions*Interventions*Phases ***/
/****************************************************/

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
  ;
run; 


proc freq data=cc_ct_;
	table Conditions*Interventions / list missing out=cond_int;
	table Conditions*Interventions*Phases / list missing out=int_ph;
run;



%macro cond_int_wt(cond=
		          ,cond_where=
				  ,int_where=
				  ,int=
		          );
title "&cond. & &int. - Trial Counts";
		proc print data=cond_int noobs ;
			where &cond_where.;
		run;
title;


			proc sql;
				create table c_i_wt_&cond._&int. as 
				select "&cond." as AOR label "Area of Research" , "&int." as INT label "Intervention", sum(count) as wt
				from cond_int
				where &cond_where. and &int_where.
				;
			quit;

		
			proc sql;
				create table i_p_wt_&cond._&int. as 
				select "&int." as INT label "Intervention", phases, sum(count) as wt
				from int_ph
				where &cond_where. and &int_where. 
				group by INT, phases
				;
			quit;

%mend;


/******* MM*LENALIDOMIDE *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "LENALIDOMIDE") > 0 or index(upcase(Interventions), "REVLIMID") > 0)
                                  )
				  ,int=LENALIDOMIDE
		          );



/******* MM*POMALIDOMIDE *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				   ,int_where=%str((index(upcase(Interventions), "POMALIDOMIDE") > 0 or index(upcase(Interventions), "POMALYST") > 0 or
                                    index(upcase(Interventions), "IMNOVID") > 0)
                                  )
				  ,int=POMALIDOMIDE
		          );


/******* MM*THALIDOMIDE *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "THALIDOMIDE") > 0 or index(upcase(Interventions), "THALOMID") > 0 )
                                  )
				  ,int=THALIDOMIDE
		          );


/******* MM*bb2121 *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "BB2121") > 0 )
                                  )
				  ,int=BB2121
		          );


/******* MM*bb21217 *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "BB21217") > 0 )
                                  )
				  ,int=BB21217
		          );

/******* MM*JCARH125 *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "JCARH125") > 0 )
                                  )
				  ,int=JCARH125
		          );

/******* MM*Iberdomide *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "IBERDOMIDE") > 0 or index(upcase(Interventions), "CC-220") > 0 )
                                  )
				  ,int=Iberdomide
		          );


/******* MM*CC-92480 *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "CC-92480") > 0 or index(upcase(Interventions), "CELMOD") > 0 )
                                  )
				  ,int=CC_92480
		          );


/******* MM*CC-93269 *********/

	  %cond_int_wt(cond=MM
		          ,cond_where=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0))
				  ,int_where=%str((index(upcase(Interventions), "CC-93269") > 0 or index(upcase(Interventions), "BCMA TCE") > 0 )
                                  )
				  ,int=CC_93269
		          );






%let mds_cond = %str(index(upcase(conditions), "MYELODYSPLASTIC SYNDROMES") > 0 or index(upcase(conditions), "MDS") > 0 or index(upcase(conditions), "MYELODYSPLASTIC") > 0);



/******* MDS*AZACITIDINE *********/

	  %cond_int_wt(cond=MDS
		          ,cond_where=%str((&mds_cond.))
				  ,int_where=%str((index(upcase(Interventions), "AZACITIDINE") > 0 or index(upcase(Interventions), "VIDAZA") > 0)
                                  )
				  ,int=AZACITIDINE
		          );





/******* MDS*LENALIDOMIDE *********/

	  %cond_int_wt(cond=MDS
		          ,cond_where=%str((&mds_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LENALIDOMIDE") > 0 or index(upcase(Interventions), "REVLIMID") > 0)
                                  )
				  ,int=LENALIDOMIDE
		          );





/******* MDS*CC-486 *********/

	  %cond_int_wt(cond=MDS
		          ,cond_where=%str((&mds_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-486") > 0 or index(upcase(Interventions), "DNMT") > 0)
                                  )
				  ,int=CC_486
		          );


/******* MDS*Luspatercept *********/

	  %cond_int_wt(cond=MDS
		          ,cond_where=%str((&mds_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LUSPATERCEPT") > 0 or index(upcase(Interventions), "ACE-536") > 0)
                                  )
				  ,int=Luspatercept
		          );


%let aml_cond = %str(index(upcase(conditions), "AML") > 0 or index(upcase(conditions), "ACUTE") > 0 or index(upcase(conditions), "MYELOID") > 0 or index(upcase(conditions), "MYELOGENOUS") > 0);



/******* AML*AZACITIDINE *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				  ,int_where=%str((index(upcase(Interventions), "AZACITIDINE") > 0 or index(upcase(Interventions), "VIDAZA") > 0)
                                  )
				  ,int=AZACITIDINE
		          );



/******* AML*CC-486 *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-486") > 0 or index(upcase(Interventions), "DNMT") > 0)
                                  )
				  ,int=CC_486
		          );


/******* AML*enasidenib *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				  ,int_where=%str((index(upcase(Interventions), "ENASIDENIB") > 0 or index(upcase(Interventions), "IDHIFA") > 0)
                                  )
				  ,int=ENASIDENIB
		          );


/******* AML*CC-90009  *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90009") > 0 or index(upcase(Interventions), "CELMOD") > 0)
                                  )
				  ,int=CC_90009 
		          );


/******* AML*GEM333  *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				   ,int_where=%str((index(upcase(Interventions), "GEM333") > 0 or index(upcase(Interventions), "CD3XCD33") > 0)
                                  )
				  ,int=GEM333 
		          );


/******* AML*CC-95775  *********/

	  %cond_int_wt(cond=AML
		          ,cond_where=%str((&aml_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-95775") > 0 or index(upcase(Interventions), "(BET INHIBITOR") > 0)
                                  )
				  ,int=CC_95775 
		          );


%let lym_cond = %str(index(upcase(conditions), "LYMPHOMA") > 0 );


/******* LYMPHOMA*LENALIDOMIDE *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LENALIDOMIDE") > 0 or index(upcase(Interventions), "REVLIMID") > 0)
                                  )
				  ,int=LENALIDOMIDE
		          );

/******* LYMPHOMA*ROMIDEPSIN *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "ROMIDEPSIN") > 0 or index(upcase(Interventions), "ISTODAX") > 0)
                                  )
				  ,int=ROMIDEPSIN
		          );

/******* LYMPHOMA*liso-cel *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LISO-CEL") > 0 or index(upcase(Interventions), "CD-19") > 0)
                                  )
				  ,int=LISO_CEL
		          );


/******* LYMPHOMA*CC-486 *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-486") > 0 or index(upcase(Interventions), "DNMT") > 0)
                                  )
				  ,int=CC_486
		          );


/******* LYMPHOMA*CC-90002 *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90002") > 0 or index(upcase(Interventions), "CD47") > 0)
                                  )
				  ,int=CC_90002
		          );


/******* LYMPHOMA*AVADOMIDE *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "AVADOMIDE") > 0 or index(upcase(Interventions), "CC-122") > 0)
                                  )
				  ,int=AVADOMIDE
		          );


/******* LYMPHOMA*CC-90010 *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90010") > 0 )
                                  )
				  ,int=CC_90010
		          );


/******* LYMPHOMA*CC-95775 *********/

	  %cond_int_wt(cond=LYMPHOMA
		          ,cond_where=%str((&lym_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-95775") > 0 )
                                  )
				  ,int=CC_95775
		          );


%let cc_cond = %str(index(upcase(conditions), "CHRONIC LYMPHOCYTIC LEUKEMIA") > 0 or index(upcase(conditions), " LYMPHOCYTIC LEUKEMIA") > 0 or index(upcase(conditions), " LYMPHOCYTIC") > 0 );

/******* CLL*LISO-CEL *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				   ,int_where=%str((index(upcase(Interventions), "LISO-CEL") > 0 or index(upcase(Interventions), "JCAR017") > 0 or index(upcase(Interventions), "LISOCABTAGENE MARALEUCEL") > 0)
                                  )
				  ,int=LISO_CEL
		          );


/******* CLL*LENALIDOMIDE *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LENALIDOMIDE") > 0 or index(upcase(Interventions), "REVLIMID") > 0)
                                  )
				  ,int=LENALIDOMIDE
		          );


/******* CLL*AVADOMIDE *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				  ,int_where=%str((index(upcase(Interventions), "AVADOMIDE") > 0 or index(upcase(Interventions), "CC-122") > 0)
                                  )
				  ,int=AVADOMIDE
		          );



/******* CLL*CC-115 *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-115") > 0 )
                                  )
				  ,int=CC_115
		          );



/******* CLL*THALIDOMIDE *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				 ,int_where=%str((index(upcase(Interventions), "THALIDOMIDE") > 0 or index(upcase(Interventions), "THALOMID") > 0 )
                                  )
				  ,int=THALIDOMIDE
		          );

/******* CLL*ROMIDEPSIN *********/

	  %cond_int_wt(cond=CLL
		          ,cond_where=%str((&cc_cond.))
				  ,int_where=%str((index(upcase(Interventions), "ROMIDEPSIN") > 0 or index(upcase(Interventions), "ISTODAX") > 0)
                                  )
				  ,int=ROMIDEPSIN
		          );



%let bt_cond = %str(index(upcase(conditions), "BETA-THALASSEMIA") > 0 or index(upcase(conditions), "THALASSEMIA") > 0 );

/******* BETA_THALASSEMIA*LUSPATERCEPT *********/

	  %cond_int_wt(cond=B_T
		          ,cond_where=%str((&bt_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LUSPATERCEPT") > 0 or index(upcase(Interventions), "ACE-536") > 0 )
                                  )
				  ,int=LUSPATERCEPT
		          );


%let mf_cond = %str(index(upcase(conditions), "MYELOFIBROSIS") > 0 or index(upcase(conditions), "MF") > 0 );

/******* MYELOFIBROSIS*LUSPATERCEPT *********/

	  %cond_int_wt(cond=MF
		          ,cond_where=%str((&mf_cond.))
				  ,int_where=%str((index(upcase(Interventions), "FEDRATINIB") > 0 )
                                  )
				  ,int=LUSPATERCEPT
		          );

/******* MYELOFIBROSIS*LUSPATERCEPT *********/

	  %cond_int_wt(cond=MF
		          ,cond_where=%str((&mf_cond.))
				  ,int_where=%str((index(upcase(Interventions), "LUSPATERCEPT") > 0 or index(upcase(Interventions), "ACE-536") > 0 )
                                  )
				  ,int=LUSPATERCEPT
		          );

%let st_cond = %str(index(upcase(conditions), "SOLID TUMORS") > 0 or index(upcase(conditions), "TUMORS") > 0 or
						 index(upcase(conditions), "BREAST") > 0 or index(upcase(conditions), "LUNG") > 0 or index(upcase(conditions), "NSCLC") > 0 or
						 index(upcase(conditions), "PANCRE") > 0 or index(upcase(conditions), "GASTR") > 0 or index(upcase(conditions), "GLIO") > 0 or
						 index(upcase(conditions), "STOMA") > 0 or index(upcase(conditions), "NEOPLASMS") > 0 or index(upcase(conditions), "HEPAT") > 0 
						 or index(upcase(conditions), "ESOPH") > 0 
						);


/******* SOLID-TUMORS*ABRAXANE *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "ABRAXANE") > 0 or index(upcase(Interventions), "PACLITAXEL") > 0 )
                                  )
				  ,int=ABRAXANE
		          );

/******* SOLID-TUMORS*MARIZOMIB *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "MARIZOMIB") > 0 )
                                  )
				  ,int=MARIZOMIB
		          );

/******* SOLID-TUMORS*TISLELIZUMAB *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "TISLELIZUMAB") > 0 or index(upcase(Interventions), "BGB-A317") > 0 )
                                  )
				  ,int=TISLELIZUMAB
		          );


/******* SOLID-TUMORS*CC-90011 *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90011") > 0 )
                                  )
				  ,int=CC_90011
		          );


/******* SOLID-TUMORS*CC-90010 *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90010") > 0 or index(upcase(Interventions), "BET") > 0)
                                  )
				  ,int=CC_90010
		          );


/******* SOLID-TUMORS*CC-95251 *********/

	  %cond_int_wt(cond=ST
		          ,cond_where=%str((&st_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-95251") > 0 )
                                  )
				  ,int=CC_95251
		          );


/*9. INFLAMMATION & IMMUNOLOGY*/
%let ii_cond = %str(index(upcase(conditions), "PSORIA") > 0 or index(upcase(conditions), "BEHCET") > 0 or
						 index(upcase(conditions), "SCLERO") > 0 or index(upcase(conditions), "COLITIS") > 0 or index(upcase(conditions), "ULCER") > 0 or
						 index(upcase(conditions), "CROHN") > 0 or index(upcase(conditions), "LUPUS") > 0 or
						 index(upcase(conditions), "FIBRO") > 0  
						);

	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "OTEZLA") > 0 or index(upcase(Interventions), "APREMILAST") > 0)
                                  )
				  ,int=OTEZLA
		          );


	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "OZANIMOD") > 0 )
                                  )
				  ,int=OZANIMOD
		          );


	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-93538") > 0 )
                                  )
				  ,int=CC_93538 
		          );


	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "IBERDOMIDE") > 0 or index(upcase(Interventions), "CC-220") > 0)
                                  )
				  ,int=IBERDOMIDE
		          );


	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90001") > 0 )
                                  )
				  ,int=CC_90001
		          );


	  %cond_int_wt(cond=II
		          ,cond_where=%str((&ii_cond.))
				  ,int_where=%str((index(upcase(Interventions), "CC-90006") > 0 )
                                  )
				  ,int=CC_90006
		          );

data c_i_all_wt;
	length AOR INT $100 ;

	set C_I_WT_: ;
run;

/***Input for Node 1-2***/
proc sql;
	create table c_all_wt1 as
	select aor, sum(wt) as sumwt
	from c_i_all_wt
	group by aor
	;
quit;
/**************************/

/***Input for Node 2-3***/
data c_i_all_wt2;
	set c_i_all_wt;
	format aor $condlbl.;
	int=upcase(int);
	int=tranwrd(int, "_", "-");
	if wt ne . then final = "[ '"||strip(put(aor, $condlbl.))||"', '"||strip(int)||"',"||strip(put(wt, 5.0))||"],";
run;
/**************************/


data i_p_all_wt;
	length INT phases $100 ;
	set i_p_wt_: ;
	int=upcase(int);
	int=tranwrd(int, "_", "-");
	if wt ne . ;
run;

proc sql;
	create table i_p_all_wt2 as
	select int, phases, sum(wt) as sumwt
	from i_p_all_wt
	group by int, phases
	;
quit;

/***Input for Node 3-4***/
data i_p_all_wt3;
	set i_p_all_wt2;
	final= "[ '"||strip(int)||"', '"||strip(phases)||"',"||strip(put(sumwt, best.))||"]," ;
run;
/**************************/




/****************************************************/
/***********************STEP 3***********************/
/* Weightage of Phases*Outcome_Measures (Endpoints) */
/****************************************************/



proc freq data=cc_ct_;
	table Phases*Outcome_Measures / list missing out=ph_om;
	where phases not in  ("Not Applicable" "Early Phase 1" "Phase 1");
run;


data ph_om_1;
	set ph_om;
	if index(compress(upcase(Outcome_Measures)), "OVERALLSURVIVAL") > 0 or index(compress(upcase(Outcome_Measures)),"(OS)") > 0 or index(compress(upcase(Outcome_Measures)),"OVERALL-SURVIVAL") > 0 then OS = 1;
	if index(compress(upcase(Outcome_Measures)), "OVERALLRESPONSERATE") > 0 or  index(compress(upcase(Outcome_Measures)), "(ORR)") > 0 or index(compress(upcase(Outcome_Measures)), "OVERALLRESPONSE") > 0 or 
       index(compress(upcase(Outcome_Measures)), "OBJECTIVERESPONSE") > 0 then ORR = 1;
	if index(compress(upcase(Outcome_Measures)), "PROGRESSIONFREE") > 0 or index(compress(upcase(Outcome_Measures)), "PFS") > 0 or index(compress(upcase(Outcome_Measures)), "PROGRESSION-FREE") > 0 then PFS = 1;
	if index(compress(upcase(Outcome_Measures)), "QUALITYOFLIFE") > 0 or index(compress(upcase(Outcome_Measures)), "QUALITY-OF-LIFE") > 0 or index(compress(upcase(Outcome_Measures)), "QOL") > 0 or index(compress(upcase(Outcome_Measures)), "(QOL)") > 0 or
	   index(compress(upcase(Outcome_Measures)), "OUTCOMES") > 0 or  index(compress(upcase(Outcome_Measures)), "HEALTHECONOMICS") > 0 or index(compress(upcase(Outcome_Measures)), "PRO)") > 0
       then QOL = 1;
	if index(compress(upcase(Outcome_Measures)), "ADVERSEEVENT") > 0 or index(compress(upcase(Outcome_Measures)), "AES") > 0 or index(compress(upcase(Outcome_Measures)), "ADVERSE") > 0 then AES = 1;
	if index(compress(upcase(Outcome_Measures)), "DOSELIMITINGTOXICIT") > 0 or index(compress(upcase(Outcome_Measures)), "DLT") > 0 or index(compress(upcase(Outcome_Measures)), "DOSE-LIMITINGTOXICIT") > 0 then DLT = 1;
	if index(compress(upcase(Outcome_Measures)), "NOTTOLERATEDDOSE") > 0 or index(compress(upcase(Outcome_Measures)), "NTD") > 0 or index(compress(upcase(Outcome_Measures)), "(NTD)") > 0 then NTD = 1;
	if index(compress(upcase(Outcome_Measures)), "MAXIMUMTOLERATEDDOSE") > 0 or index(compress(upcase(Outcome_Measures)), "MTD") > 0 or index(compress(upcase(Outcome_Measures)), "(MTD)") > 0 then MTD = 1;
	if index(compress(upcase(Outcome_Measures)), "DURATIONOFRESPONSE") > 0 or index(compress(upcase(Outcome_Measures)), "DOR") > 0 or index(compress(upcase(Outcome_Measures)), "(DOR)") > 0 then DOR = 1;
	if index(compress(upcase(Outcome_Measures)), "AREAUNDER") > 0 or index(compress(upcase(Outcome_Measures)), "AUC") > 0 or index(compress(upcase(Outcome_Measures)), "CURVE") > 0 then AUC = 1;
	if index(compress(upcase(Outcome_Measures)), "TMAX") > 0 or index(compress(upcase(Outcome_Measures)), "T-MAX") > 0 then TMAX = 1;
	if index(compress(upcase(Outcome_Measures)), "T1/2") > 0 or index(compress(upcase(Outcome_Measures)), "half") > 0 then T1_2 = 1;
	if index(compress(upcase(Outcome_Measures)), "TIMETORESPONSE") > 0 or index(compress(upcase(Outcome_Measures)), "TIME-TO-RESPONSE") > 0 or index(compress(upcase(Outcome_Measures)), "TTR") > 0  or 
       index(compress(upcase(Outcome_Measures)), "T2R") > 0 or index(compress(upcase(Outcome_Measures)), "TIMETOONSETOFRESPONSE") > 0 then T2R = 1;
	if index(compress(upcase(Outcome_Measures)), "CLINICALBENEFITRATE") > 0 or index(compress(upcase(Outcome_Measures)), "CBR") > 0 then CBR = 1;
	if index(compress(upcase(Outcome_Measures)), "RELAPSEFREESURVIVAL") > 0 or index(compress(upcase(Outcome_Measures)), "RFS") > 0 or index(compress(upcase(Outcome_Measures)), "RELAPSE-FREESURVIVAL") > 0 then RFS = 1;
	if index(compress(upcase(Outcome_Measures)), "EVENTFREESURVIVAL") > 0 or index(compress(upcase(Outcome_Measures)), "EFS") > 0 or index(compress(upcase(Outcome_Measures)), "EVENT-FREESURVIVAL") > 0 then EFS = 1;
	if index(compress(upcase(Outcome_Measures)), "DISEASEFREESURVIVAL") > 0 or index(compress(upcase(Outcome_Measures)), "DFS") > 0 or index(compress(upcase(Outcome_Measures)), "DISEASE-FREESURVIVAL") > 0 then DFS = 1;
	if index(compress(upcase(Outcome_Measures)), "LEUKEMIAFREESURVIVAL") > 0 or index(compress(upcase(Outcome_Measures)), "LFS") > 0 or index(compress(upcase(Outcome_Measures)), "LEUKEMIA-FREESURVIVAL") > 0 then LFS = 1;
	if index(compress(upcase(Outcome_Measures)), "COMPLETERESPONSE") > 0 or  index(compress(upcase(Outcome_Measures)), "(CR") > 0 or index(compress(upcase(Outcome_Measures)), "COMPLETE-RESPONSE") > 0 then CR = 1;
	if index(compress(upcase(Outcome_Measures)), "PARTIALRESPONSE") > 0 or  index(compress(upcase(Outcome_Measures)), "(PR") > 0 or index(compress(upcase(Outcome_Measures)), "PARTIAL-RESPONSE") > 0 then PR = 1;
	if index(compress(upcase(Outcome_Measures)), "TIMETOPROGRESSION") > 0 or index(compress(upcase(Outcome_Measures)), "TIME-TO-PROGRESSION") > 0 or index(compress(upcase(Outcome_Measures)), "TTP") > 0  or index(compress(upcase(Outcome_Measures)), "T2P") > 0 then TTP = 1;
	if index(compress(upcase(Outcome_Measures)), "CYTOGENETICRESPONSE") > 0 or index(compress(upcase(Outcome_Measures)), "CYTOGENETIC-RESPONSE") > 0 or index(compress(upcase(Outcome_Measures)), "CYTOGENETIC") > 0  then CYTO = 1;
	if index(compress(upcase(Outcome_Measures)), "PAIN") > 0 or index(compress(upcase(Outcome_Measures)), "BRIEFPAININVENTORY") > 0 or index(compress(upcase(Outcome_Measures)), "BPI") > 0  then BPI = 1;
	if index(compress(upcase(Outcome_Measures)), "DISEASERESPONSE") > 0 or  index(compress(upcase(Outcome_Measures)), "(DCR") > 0 or index(compress(upcase(Outcome_Measures)), "DISEASE-RESPONSE") > 0 then DCR = 1;

run;


%macro ph_om_wt(om=);


proc freq data=ph_om_1;
	table phases*&om. / list missing  out=__&om.(where=(&om. ne .) drop=percent );
run;

data __&om.;
length out_meas $100;
	set __&om.(drop=&om.);
	out_meas = upcase("&om.");
run;

%mend ph_om_wt;

	%ph_om_wt(om=OS);   
	%ph_om_wt(om=ORR);  
	%ph_om_wt(om=PFS);  
	%ph_om_wt(om=QOL);  

	%ph_om_wt(om=AES);  
	%ph_om_wt(om=DLT);  

	%ph_om_wt(om=DOR); 
	%ph_om_wt(om=AUC); 
	%ph_om_wt(om=tmax); 
	%ph_om_wt(om=t1_2); 

	%ph_om_wt(om=t2r);  
	%ph_om_wt(om=CBR); 
	%ph_om_wt(om=RFS); 
	%ph_om_wt(om=EFS);

	%ph_om_wt(om=DFS); 
	%ph_om_wt(om=LFS); 
	%ph_om_wt(om=CR); 
	%ph_om_wt(om=PR); 

	%ph_om_wt(om=TTP); 
	%ph_om_wt(om=cyto); 
	%ph_om_wt(om=bpi); 
	%ph_om_wt(om=dcr); 

data om_Wt;
	set __: ;
	if count >= 5;
	final = "[ '"||strip(phases)||"', '"||strip(out_meas)||"',"||strip(put(count, best.))||"],";
run;
proc sort data=om_wt;
	by Phases out_meas ;
run;

/************************************************************/




/*****************************************************/
/***********************STEP 4************************/
/** Weightage of Outcome_Measures (Endpoints)*ADaMs **/
/*****************************************************/

proc sql;
	create table om_wt_unq as
	select distinct out_meas, sum(count) as wt
	from om_wt
	group by out_meas
	;
quit;


data om_wt_ad;
	length adam $100;
	set om_wt_unq;

	if out_meas = "OS"   then adam = "ADTTE";   
	if out_meas = "ORR"  then adam = "ADRS";  
	if out_meas = "PFS"  then adam = "ADTTE";  
	if out_meas = "QOL"  then adam = "ADPRO";  

	if out_meas = "AES"  then adam = "ADAE";  
	if out_meas = "DLT"  then adam = "ADAE";  

	if out_meas = "DOR"  then adam = "ADTTE"; 
	if out_meas = "AUC"  then adam = "ADPP"; 
	if out_meas = "TMAX" then adam = "ADPP"; 
	if out_meas = "T1_2" then adam = "ADPP"; 

	if out_meas = "T2R"  then adam = "ADTTE";  
	if out_meas = "CBR"  then adam = "ADRS"; 
	if out_meas = "RFS"  then adam = "ADTTE"; 
	if out_meas = "EFS"  then adam = "ADTTE";

	if out_meas = "DFS"  then adam = "ADTTE"; 
	if out_meas = "LFS"  then adam = "ADTTE"; 
	if out_meas = "CR"   then adam = "ADRS"; 
	if out_meas = "PR"   then adam = "ADRS"; 

	if out_meas = "TTP"  then adam = "ADTTE"; 
	if out_meas = "CYTO" then adam = "ADRS"; 
	if out_meas = "BPI"  then adam = "ADPRO"; 
	if out_meas = "DCR"  then adam = "ADRS"; 

	final = "[ '"||strip(out_meas)||"', '"||strip(adam)||"',"||strip(put(wt, best.))||"],";

run;





