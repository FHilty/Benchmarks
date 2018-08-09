#Benchmark problem 1a

[Problem]
  type = FEProblem
  coord_type = XYZ
[]

[Mesh]
  type = FileMesh
  file = sphere_mesh.e
[]

[Functions]
  [./C_IC_Function]
    type = ParsedFunction
    value = '0.5+0.05*(cos(8*acos(z/100))*cos(15*atan(y/x))+(cos(12*acos(z/100))*cos(10*atan(y/x)))^2+cos(2.5*acos(z/100)-1.5*atan(y/x))*cos(7*acos(z/100)-2*atan(y/x)))'
  [../]
  [./ETA1_IC_Function]
    type = ParsedFunction
    value = '0.1*(cos(i*acos(z/100)-4)*cos((0.7+i)*atan(y/x))+cos((11+i)*acos(z/100))*cos((11+i)*atan(y/x))+1.5*(cos((4.6+0.1*i)*acos(z/100)+(4.05+0.1*i)*atan(y/x))*cos((3.1+0.1*i)*acos(z/100)-(0.4+0.1*i)*atan(y/x)))^2)^2'
    vars = 'i'
    vals = 1
  [../]
  [./ETA2_IC_Function]
    type = ParsedFunction
    value = '0.1*(cos(i*acos(z/100)-4)*cos((0.7+i)*atan(y/x))+cos((11+i)*acos(z/100))*cos((11+i)*atan(y/x))+1.5*(cos((4.6+0.1*i)*acos(z/100)+(4.05+0.1*i)*atan(y/x))*cos((3.1+0.1*i)*acos(z/100)-(0.4+0.1*i)*atan(y/x)))^2)^2'
    vars = 'i'
    vals = 2
  [../]
  [./ETA3_IC_Function]
    type = ParsedFunction
    value = '0.1*(cos(i*acos(z/100)-4)*cos((0.7+i)*atan(y/x))+cos((11+i)*acos(z/100))*cos((11+i)*atan(y/x))+1.5*(cos((4.6+0.1*i)*acos(z/100)+(4.05+0.1*i)*atan(y/x))*cos((3.1+0.1*i)*acos(z/100)-(0.4+0.1*i)*atan(y/x)))^2)^2'
    vars = 'i'
    vals = 3
  [../]
  [./ETA4_IC_Function]
    type = ParsedFunction
    value = '0.1*(cos(i*acos(z/100)-4)*cos((0.7+i)*atan(y/x))+cos((11+i)*acos(z/100))*cos((11+i)*atan(y/x))+1.5*(cos((4.6+0.1*i)*acos(z/100)+(4.05+0.1*i)*atan(y/x))*cos((3.1+0.1*i)*acos(z/100)-(0.4+0.1*i)*atan(y/x)))^2)^2'
    vars = 'i'
    vals = 4
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
     function = C_IC_Function
     variable = c
  [../]
  [./ETA1_IC]
    type = FunctionIC
     function = ETA1_IC_Function
     variable = eta1
  [../]
  [./ETA2_IC]
    type = FunctionIC
     function = ETA2_IC_Function
     variable = eta2
  [../]
  [./ETA3_IC]
    type = FunctionIC
     function = ETA3_IC_Function
     variable = eta3
  [../]
  [./ETA4_IC]
    type = FunctionIC
     function = ETA4_IC_Function
     variable = eta4
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
    f_name = 'Fchem'
    kappa_names = 'kappa_c'
    interfacial_vars = c
  [../]
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./eta1]
  [../]
  [./eta2]
  [../]
  [./eta3]
  [../]
  [./eta4]
  [../]
[]

[Kernels]
  [./deta1dt]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulk1]
    type = AllenCahn
    variable = eta1
    args = 'c eta2 eta3 eta4'
    f_name = Fchem
  [../]
  [./ACInterface1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa_eta
  [../]
  [./deta2dt]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulk2]
    type = AllenCahn
    variable = eta2
    args = 'c eta1 eta3 eta4'
    f_name = Fchem
  [../]
  [./ACInterface2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa_eta
  [../]
  [./deta3dt]
    type = TimeDerivative
    variable = eta3
  [../]
  [./ACBulk3]
    type = AllenCahn
    variable = eta3
    args = 'c eta1 eta2 eta4'
    f_name = Fchem
  [../]
  [./ACInterface3]
    type = ACInterface
    variable = eta3
    kappa_name = kappa_eta
  [../]
  [./deta4dt]
    type = TimeDerivative
    variable = eta4
  [../]
  [./ACBulk4]
    type = AllenCahn
    variable = eta4
    args = 'c eta1 eta2 eta3'
    f_name = Fchem
  [../]
  [./ACInterface4]
    type = ACInterface
    variable = eta4
    kappa_name = kappa_eta
  [../]

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
    f_name = Fchem
    kappa_name = kappa_c
    w = w
    variable = c
    args = 'eta1 eta2 eta3 eta4'
  [../]
[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Materials]
  [./Constants]
    type = GenericConstantMaterial
    prop_names = '  M   L    kappa_c   kappa_eta'
    prop_values = '5.0 5.0     3.0        3.0'
  [../]
  [./switching]
    type = DerivativeParsedMaterial
    f_name = h
    args = 'eta1 eta2 eta3 eta4'
    function = 'eta1^3*(6*eta1^2-15*eta1+10)+eta2^3*(6*eta2^2-15*eta2+10)+eta3^3*(6*eta3^2-15*eta3+10)+eta4^3*(6*eta4^2-15*eta4+10)'
  [../]
  [./barrier]
    type = DerivativeParsedMaterial
    f_name = g
    args = 'eta1 eta2 eta3 eta4'
    function  = 'eta1^2*(1-eta1)^2+eta2^2*(1-eta2)^2+eta3^2*(1-eta3)^2+eta4^2*(1-eta4)^2+5*2*(eta1^2*eta2^2+eta1^2*eta3^2+eta1^2*eta4^2+eta2^2*eta3^2+eta2^2*eta4^2+eta3^2*eta4^2)'
  [../]
  [./free_energy_A]
    type = DerivativeParsedMaterial
    f_name = Fa
    args = 'c'
    constant_names = 'ca'
    constant_expressions = '0.3'
    function = '2*(c-ca)^2'
    derivative_order = 2
  [../]
  [./free_energy_B]
    type = DerivativeParsedMaterial
    f_name = Fb
    args = 'c'
    constant_names = 'cb'
    constant_expressions = '0.7'
    function = '2*(cb-c)^2'
    derivative_order = 2
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    f_name = Fchem
    function = 'Fa*(1-h)+Fb*h+W*g'
    constant_names = 'W'
    constant_expressions = 1.0
    material_property_names = 'Fa(c) Fb(c) h(eta1,eta2,eta3,eta4) g(eta1,eta2,eta3,eta4)'
    args = 'c eta1 eta2 eta3 eta4'
    derivative_order = 2
  [../]
[]

# [Executioner]
#   type = Transient
#   scheme = bdf2
#   solve_type = NEWTON
#   nl_abs_tol = 1e-11
#   nl_rel_tol = 1e-8
#   petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type
#                          -sub_pc_type -pc_asm_overlap'
#   petsc_options_value = 'asm      31                  preonly
#                          lu          2'
#   l_max_its = 20
#   nl_max_its = 20
#   end_time = 1.1e+5
#   dtmax = 1e+4
#   [./Adaptivity]
#     max_h_level = 5
#     coarsen_fraction = 0.1
#     refine_fraction = 0.7
#   [../]
#   [./TimeStepper]
#     type = SolutionTimeAdaptiveDT
#     dt = 0.01
#     percent_change = 0.1
#     initial_direction = 1
#   [../]
# []

[Executioner]
  type = Transient
  solve_type = NEWTON
  l_max_its = 30
  l_tol = 1e-6
  nl_max_its = 30
  nl_abs_tol = 1e-9
  num_steps = 1000
  dtmax = 1e+6
  #end_time = 604800   # 7 days
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm lu'
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-3
    cutback_factor = 0.8
    growth_factor = 1.5
    optimal_iterations = 7
  [../]
  [./Adaptivity]
    coarsen_fraction = 0.1
    refine_fraction = 0.7
    max_h_level = 2
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
  [./physical]
    type = MemoryUsage
    mem_type = physical_memory
    value_type = total
    # by default MemoryUsage reports the peak value for the current timestep
    # out of all samples that have been taken (at linear and non-linear iterations)
    execute_on = 'INITIAL TIMESTEP_END NONLINEAR LINEAR'
  [../]
  [./walltime]
    type = PerformanceData
    event = ALIVE
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
[]
