import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar2";
import ProjectCard from "../components/ProjectCard";

export default function DashboardLayout() {
  return (
    <div className="flex">
    <Sidebar />              
      <div className="flex-1 bg-gray-50">
        <div className="p-6">
          <h2 className="text-xl font-bold mb-4">Projects</h2>
          <p className="text-gray-500 mb-6">Architects design houses</p>
          <div className="flex gap-6 flex-wrap">
            <ProjectCard
              title="Modern"
              subtitle="Project #2"
              description="As Uber works through a huge amount of internal management turmoil."
              image="https://i.imgur.com/E0tjlYt.png"
            />
            <ProjectCard
              title="Scandinavian"
              subtitle="Project #1"
              description="Music is something that every person has his or her own specific opinion about."
              image="https://i.imgur.com/kK1iEbM.png"
            />
            <ProjectCard
              title="Minimalist"
              subtitle="Project #3"
              description="Different people have different taste, and various types of music."
              image="https://i.imgur.com/bcWqXik.png"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
