#Benchmark problem 1a

[Problem]
  type = FEProblem
  coord_type = XYZ
[]

[Mesh]
  type = FileMesh
  file = sphere_mesh.e
  uniform_refine = 2
[]

[Functions]
  [./IC_Function]
    type = ParsedFunction
    value = '0.5+0.05*(cos(8*acos(z/100))*cos(15*atan(y/x))+(cos(12*acos(z/100))*cos(10*atan(y/x)))^2+cos(2.5*acos(z/100)-1.5*atan(y/x))*cos(7*acos(z/100)-2*atan(y/x)))'
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
     function = IC_Function
     variable = c
  [../]
[]

[AuxVariables]
  [./f_density]   # Local energy density (eV/mol)
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  # Calculates the energy density by combining the local and gradient energies
  [./f_density]   # (eV/mol/nm^2)
    type = TotalFreeEnergy
    variable = f_density
    f_name = 'f_loc'
    kappa_names = 'kappa'
    interfacial_vars = c
  [../]
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
[]

[Kernels]
  [./w_dot]
    type = CoupledTimeDerivative
    v = c
    variable = w
  [../]
  [./coupled_res]
    type = SplitCHWRes
    mob_name = M
    variable = w
  [../]
  [./coupled_parsed]
    type = SplitCHParsed
    f_name = f_loc
    kappa_name = kappa
    w = w
    variable = c
  [../]
[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'kappa M'
    prop_values = '2.0 5.0'
  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = c
    constant_names = 'q ca cb'
    constant_expressions = '5 0.3 0.7'
    function = 'q*(c-ca)^2*(cb-c)^2'
    derivative_order = 2
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  nl_abs_tol = 1e-11
  nl_rel_tol = 1e-8
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type
                         -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly
                         lu          2'
  l_max_its = 20
  nl_max_its = 20
  end_time = 1e+6
  [./Adaptivity]
    max_h_level = 2
    coarsen_fraction = 0.1
    refine_fraction = 0.7
  [../]
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 1
    percent_change = 0.1
    initial_direction = 1
  [../]
[]

[Outputs]
  print_perf_log = true
#  exodus = true
  csv = true
  file_base = ./Results/output
  [./Exodus]
    type = Exodus
    output_dimension = 3
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[Postprocessors]
  [./step_size]             # Size of the time step
    type = TimestepSize
  [../]
  [./total_energy]          # Total free energy at each timestep
    type = ElementIntegralVariablePostprocessor
    variable = f_density
  [../]
[]
