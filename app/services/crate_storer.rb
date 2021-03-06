class CrateStorer
  def initialize(shelving_unit, crate)
    @shelving_unit = shelving_unit
    @crate = crate
  end

  def call
    coords = @crate.all_crate_coords

    if crate_fits_in_shelving_unit?(coords)
      coords.each { |coord| @shelving_unit.update_representation(coord, @crate) }
    else
      false
    end
  end

  private

  def crate_fits_in_shelving_unit?(coords)
    coords.all? { |coord| @shelving_unit.in_position(coord[:x], coord[:y]) == nil }
  end
end
