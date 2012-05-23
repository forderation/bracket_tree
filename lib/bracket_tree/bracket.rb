require 'bracket_tree/node'

module BracketTree
  class Bracket
    class NoSeedOrderError < Exception ; end
    class SeedLimitExceededError < Exception ; end

    include Enumerable
    attr_accessor :root, :seed_order, :insertion_order

    def initialize
      @insertion_order = []
    end

    # Adds a Node at the given position, setting the data as the payload. Maps to
    # binary tree under the hood.  The `data` can be any serializable object.
    #
    # @param Fixnum position - Seat position to add
    # @param Object data - the player object to store in the Seat position
    def add position, data
      node = Node.new position, data
      @insertion_order << position

      if @root.nil?
        @root = node
      else
        current = @root
        loop do
          if node.position < current.position
            if current.left.nil?
              current.left = node
              break
            else
              current = current.left
            end
          elsif node.position > current.position
            if current.right.nil?
              current.right = node
              break
            else
              current = current.right
            end
          else
            break
          end
        end
      end
    end

    # Replaces the data at a given node position with new payload. This is useful
    # for updating bracket data, replacing placeholders with actual data, seeding,
    # etc..
    #
    # @param [Fixnum] position - the node position to replace
    # @param payload - the new payload object to replace
    def replace position, payload
      node = at position
      if node
        node.payload = payload
        true
      else
        nil
      end
    end

    # Seeds bracket based on `seed_order` value of bracket.  Provide an iterator
    # with players that will be inserted in the appropriate location.  Will raise a
    # SeedLimitExceededError if too many players are sent, and a NoSeedOrderError if
    # the `seed_order` attribute is nil
    #
    # @param [Enumerable] players - players to be seeded
    def seed players
      if @seed_order.nil?
        raise NoSeedOrderError, 'Bracket does not have a seed order.'
      elsif players.size > @seed_order.size
        raise SeedLimitExceededError, 'cannot seed more players than seed order list.'
      else
        @seed_order.each do |position|
          replace position, players.shift
        end
      end
    end

    def winner
      @root.payload
    end

    def each(&block)
      in_order(@root, block)
    end

    def to_h
      @root.to_h
    end

    # returns an array of nodes based on insertion_order
    def to_a
      entries.sort_by { |node| @insertion_order.index(node.position) }
    end

    alias_method :nodes, :to_a

    def at position
      find { |n| n.position == position }
    end

    alias_method :size, :count

    def in_order(node, block)
      if node
        unless node.left.nil?
          in_order(node.left, block)
        end

        block.call(node)

        unless node.right.nil?
          in_order(node.right, block)
        end
      end
    end
  end
end
