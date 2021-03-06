require './app/models/shelving_unit'
require './app/models/crate'
require './app/services/crate_storer'
require './app/services/crate_locator'
require './app/services/crate_remover'
require './app/services/crate_taker'
require './app/services/shelving_unit_printer'

class SimpleWarehouse
  attr_reader :shelving_unit

  def run
    @live = true
    puts 'Type `help` for instructions on usage'
    while @live
      print '> '
      interpret_command(gets.chomp)
    end
  end

  def interpret_command(command)
    arr = command.split(" ")
    verb, *args = arr
    case verb
    when 'help'
      output = show_help_message
    when 'init'
      output = create_empty_shelving_unit(args)
    when 'store'
      output = store_crate(args)
    when 'locate'
      output = locate_crate(args)
    when 'remove'
      output = remove_crate(args)
    when 'take'
      output = take_from_crate(args)
    when 'view'
      output = @shelving_unit.print_to_screen
    when 'exit'
      output = exit
    else
      output = show_unrecognized_message
    end
    ENV['testmode'] ? output : puts(output)
  end

  private

  def show_help_message
    'help               Shows this help message
init W H           (Re)Initialises the application as a W x H warehouse, with all spaces empty.
store X Y W H P Q  Stores a crate of a quantity of Q of product number P and of size W x H at position X,Y.
locate P           Show a list of positions where product number can be found.
remove X Y         Remove the crate at positon X,Y.
take Q X Y         Take out Q number of the product in crate at position X,Y.
view               Show a representation of the current state of the warehouse, marking each position as filled or empty.
exit               Exits the application.'
  end

  def create_empty_shelving_unit(args)
    @shelving_unit = ShelvingUnit.new(args[0].to_i, args[1].to_i)
    "Empty shelving unit of width: #{args[0]} and height: #{args[1]} created"
  end

  def store_crate(args)
    crate = Crate.new(args[0].to_i, args[1].to_i, args[2].to_i, args[3].to_i, args[4], args[5].to_i)

    if CrateStorer.new(@shelving_unit, crate).call
      "Crate of product #{args[4]} has been placed at coords #{args[0]}, #{args[1]}"
    else
      "Invalid placement of crate; please try again."
    end
  end

  def locate_crate(args)
    locations = CrateLocator.new(@shelving_unit, args[0]).call

    if locations.empty?
      "We out out of stock of product #{args[0]}"
    else
      "Product #{args[0]} can be found at the following locations: #{locations.join(', ')}"
    end
  end

  def remove_crate(args)
    crate = @shelving_unit.in_position(args[0].to_i, args[1].to_i)

    if crate.nil?
      "There is no crate at location: [x: #{args[0]}, y: #{args[1]}]"
    else
      CrateRemover.new(@shelving_unit, crate).call
      "Product #{crate.product_code} removed from location [x: #{args[0]}, y: #{args[1]}] (crate origin: [x: #{crate.x}, y: #{crate.y}])"
    end
  end

  def take_from_crate(args)
    crate = @shelving_unit.in_position(args[1].to_i, args[2].to_i)
    if CrateTaker.new(@shelving_unit, crate, args[0].to_i).call
      "#{args[0]} amount of product #{crate.product_code} removed successfully"
    else
      "Not enough quantity of stock to complete command"
    end
  end


  def show_unrecognized_message
    'Command not found. Type `help` for instructions on usage'
  end

  def exit
    @live = false
    'Thank you for using simple_warehouse!'
  end
end
