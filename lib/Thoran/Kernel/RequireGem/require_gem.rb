# Thoran/Kernel/RequireGem/require_gem.rb
# Thoran::Kernel::RequireGem#require_gem.rb

# 20240613
# 0.0.0

module Thoran
  module Kernel
    module RequireGem

      def require_gem(load_string, gem_name: nil)
        require load_string
      rescue LoadError
        if gem_name
          system("gem install #{gem_name}")
        else
          system("gem install #{load_string}")
        end
        Gem.clear_paths
        require load_string
      end

    end
  end
end

Kernel.include(Thoran::Kernel::RequireGem)
