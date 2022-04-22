



data chk;
	set ptc_ct_cont;
run;

proc sql;
	create table cond_int as
	select a.name as cond, b.name as int, "cond_int_adv" as macnm
	from ptc_ct_cont(where=(substr(name,1,5) = "COND_")) as a, ptc_ct_cont(where=(substr(name,1,3) = "PTC")) as b
	;
quit;


%macro cond_int_adv(_cond=, _int=);

	proc freq data=ptc_ct_da noprint;
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


