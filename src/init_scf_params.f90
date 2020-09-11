subroutine init_scf_params()
!----------------------------------------------------------------------------------------------------------!
use eos
use flags
use parser_vars
use constants
use write_helper
!----------------------------------------------------------------------------------------------------------!
implicit none
!----------------------------------------------------------------------------------------------------------!
real(8) :: get_auto_wall_pos
real(8) :: ds_matrix_aux
!----------------------------------------------------------------------------------------------------------!
write(iow,'(A85)')adjl('-----------------------------INITIALIZE THE SCF PARAMETERS---------------------------',85)
write(*  ,'(A85)')adjl('-----------------------------INITIALIZE THE SCF PARAMETERS---------------------------',85)

Rg2_per_mon  = bond_length**2 * CN / 6.d00

if (matrix_exist) then
    ns_matrix           = 2 * nint(0.5d0 * chainlen_matrix / ds_ave_matrix)
    ns_matrix_aux       = ns_matrix
    ds_matrix_aux       = ds_ave_matrix
    chainlen_matrix_aux = chainlen_matrix
    write(iow,'(3X,A45,F16.4,'' Angstrom'')') adjl('Matrix radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_matrix)
    write(*  ,'(3X,A45,F16.4,'' Angstrom'')') adjl('Matrix radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_matrix)
    write(iow,'(3X,A45,I16,'' nodes'')')      adjl('Matrix nodes along chain contour:',45), ns_matrix
    write(*  ,'(3X,A45,I16,'' nodes'')')      adjl('Matrix nodes along chain contour:',45), ns_matrix
endif
if (grafted_lo_exist) then
    ns_grafted_lo       = 2 * nint(0.5d0 * chainlen_grafted_lo / ds_ave_grafted_lo)
    ns_matrix_aux       = ns_grafted_lo
    ds_matrix_aux       = ds_ave_grafted_lo
    chainlen_matrix_aux = chainlen_grafted_lo
    write(iow,'(3X,A45,F16.4,'' Angstrom'')') adjl('grafted lo radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_grafted_lo)
    write(*  ,'(3X,A45,F16.4,'' Angstrom'')') adjl('grafted lo radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_grafted_lo)
    write(iow,'(3X,A45,I16,'' nodes'')')      adjl('grafted lo nodes along chain contour:',45), ns_grafted_lo
    write(*  ,'(3X,A45,I16,'' nodes'')')      adjl('grafted lo nodes along chain contour:',45), ns_grafted_lo
endif
if (grafted_hi_exist) then
    ns_grafted_hi       = 2 * nint(0.5d0 * chainlen_grafted_hi / ds_ave_grafted_hi)
    ns_matrix_aux       = ns_grafted_hi
    ds_matrix_aux       = ds_ave_grafted_hi
    chainlen_matrix_aux = chainlen_grafted_hi
    write(iow,'(3X,A45,F16.4,'' Angstrom'')') adjl('grafted hi radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_grafted_hi)
    write(*  ,'(3X,A45,F16.4,'' Angstrom'')') adjl('grafted hi radious of gyration:',45), sqrt(Rg2_per_mon*chainlen_grafted_hi)
    write(iow,'(3X,A45,I16,'' nodes'')')      adjl('grafted hi nodes along chain contour:',45), ns_grafted_hi
    write(*  ,'(3X,A45,I16,'' nodes'')')      adjl('grafted hi nodes along chain contour:',45), ns_grafted_hi
endif

! miscellenious checks 
if ((matrix_exist    .and.abs(ds_matrix_aux-ds_ave_matrix)    >tol) .or. &
&   (grafted_lo_exist.and.abs(ds_matrix_aux-ds_ave_grafted_lo)>tol) .or. &
&   (grafted_hi_exist.and.abs(ds_matrix_aux-ds_ave_grafted_hi)>tol)) then
    write(iow,*) "Error: the nonconstant contour discret scheme does not work with different chain lengths."
    write(*  ,*) "Error: the nonconstant contour discret scheme does not work with different chain lengths."
    STOP
endif


if (eos_type.eq.F_sanchez_labombe) then
    write(iow,'(3X,A45)') adjl("Computation of the mass density from SL EoS..",45)
    write(*  ,'(3X,A45)') adjl("Computation of the mass density from SL EoS..",45)
    V_star         = boltz_const_Joule_K * T_star / P_star
    T_tilde        = Temp  / T_star
    P_tilde        = Pressure / P_star
    rsl_N          = (mon_mass * P_star) / (rho_star * 1.d03 * boltz_const_Joule_molK * T_star)         
    rho_tilde_bulk = eos_rho_tilde_0(T_tilde, P_tilde, rsl_N*chainlen_matrix)
    rho_mass_bulk  = rho_tilde_bulk * rho_star
    rho_mass_bulk  = rho_mass_bulk
    write(iow,'(3X,A45,F16.4,'' g/cm3'')')adjl('mass density was recomputed as:',45), rho_mass_bulk/gr_cm3_to_kg_m3
    write(*  ,'(3X,A45,F16.4,'' g/cm3'')')adjl('mass density was recomputed as:',45), rho_mass_bulk/gr_cm3_to_kg_m3

    k_gr = 2.d0 * P_star * rsl_N**2 * V_star**(8.d0/3.d0) * k_gr_tilde

end if

rho_mol_bulk = rho_mass_bulk/mon_mass*gr_cm3_to_kg_m3
rho_seg_bulk = rho_mol_bulk*N_avog

write(iow,'(3X,A45,F16.4,'' mol/m3'')')adjl('molar density in bulk',45), rho_mol_bulk
write(*  ,'(3X,A45,F16.4,'' mol/m3'')')adjl('molar density in bulk',45), rho_mol_bulk

if (wall_auto) then
    wall_pos = get_auto_wall_pos()
    write(iow,'(3X,A45,F16.9,'' Angstrom'')')adjl("wall_pos was recalibrated to",45), wall_pos
    write(*  ,'(3X,A45,F16.9,'' Angstrom'')')adjl("wall_pos was recalibrated to",45), wall_pos
endif
!----------------------------------------------------------------------------------------------------------!
end subroutine init_scf_params